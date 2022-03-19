var Cred = artifacts.require('./Cred.sol');
const { assert } = require('console');
const truffleAssert = require('truffle-assertions');
const { MerkleTree } = require('merkletreejs')
const SHA256 = require('crypto-js/sha256')

contract('Cred', function(accounts) {

  var cInstance = null;

  beforeEach(async () => {
    cInstance = await Cred.deployed();
  });

  it('Add admin', async() => {
    let addAd = await cInstance.addAdmin(accounts[8], {from : accounts[0]});
    truffleAssert.eventEmitted(addAd, "addedAdmin");
  });

  it("Don't allow non-admins to add admins", async() => {
    let badAd = cInstance.addAdmin(accounts[6], {from : accounts[2]});
    await truffleAssert.reverts(badAd, "Not Admin!");
  });


  it('Add institution from first admin', async () => {
    let giveAcc = await cInstance.addInstitution(accounts[1], {from : accounts[0]});
    truffleAssert.eventEmitted(giveAcc, "institutionListed");
    let testAddInst = await cInstance.getInstitutionStatus(accounts[1]);
    assert(testAddInst.valueOf(), true, "Not Adding Institution Correctly");
  });

  it('Add institution from added admin', async () => {
    let giveAcc = await cInstance.addInstitution(accounts[7], {from : accounts[8]});
    truffleAssert.eventEmitted(giveAcc, "institutionListed");
    let testAddInst = await cInstance.getInstitutionStatus(accounts[7]);
    assert(testAddInst.valueOf(), true, "Not Adding Institution Correctly");
  });

  it('Do not Add institution if unauthorized', async () => {
    let giveAcc = cInstance.addInstitution(accounts[3], {from : accounts[3]});
    await truffleAssert.reverts(giveAcc, "Not Admin!");
  });

  it('Allow institution to issue credential', async () => {
    let o = accounts[2]; // Owner
    let p = "abcde"; // Pointer contents
    
    let doIssue = await cInstance.issueEduCred(o, p, { from: accounts[1]});
    truffleAssert.eventEmitted(doIssue, "credentialIssued");
  });

  it('Do not allow non-institution to issue credential', async () => {
    let o = accounts[2];
    let p = "abcde";
    
    let doIssue = cInstance.issueEduCred(o, p, { from: accounts[4] });
    await truffleAssert.reverts(doIssue, "Not a verified institution!");
  });

  it('Allow owner to verify that they own a credential', async() => {
    let getCred = await cInstance.getCredentialOwned(0, {from:accounts[2]});
    assert(getCred, "abcde", "Incorrect Pointer");
  });

  it('Do not allow non-owner to get cred', async() => {
    let getCred = cInstance.getCredentialOwned(0, {from:accounts[3]});
    await truffleAssert.reverts(getCred, "Can't access credential");
  });

  it('Allow update of access list', async() => {
    // Adding account 4 to access list of credential id 0

    // First calculate merkle root

    // What we do on owner's machine/browser:
    let a4 = accounts[4];
    const leaves = [a4].map(x => SHA256(x)); // Add leaves to construct tree
    const tree = new MerkleTree(leaves, SHA256); // Construct tree
    const root = tree.getRoot().toString('hex'); // Get root
    const leaf = SHA256(a4); // Take an example leaf
    const proof = tree.getProof(leaf); // Proof that leaf in tree
    // console.log(tree.verify(proof, leaf, root)) // verifies and outputs a boolean if true or false;

    // Put merkel root in the desired credential --> Push to chain
    let addAcc = await cInstance.updateAccessList(0, root, {from: accounts[2]});

    truffleAssert.eventEmitted(addAcc, "addedAccess");

  })

  // Account 2 is owner, Account 4 is verifier
  it('Allow 3rd party to perform verification', async() => {
    let req = await cInstance.verifyCredentials(0, {from:accounts[4]});
  
    let eventRes = req.logs[0].args;
    truffleAssert.eventEmitted(req, 'requestCredential');

    // console.log("MRoot = ", eventRes[2]);
    // console.log("Address = ", eventRes[1])
    // console.log("ID = ", eventRes[0]['words'][0]);

    let id = eventRes[0]['words'][0];
    let verifier = eventRes[1];
    let mroot = eventRes[2];

    // Calculate merkle root and compare
    // Get old tree --> Simulated
    const leaves = [accounts[4]].map(x => SHA256(x)); // Add leaves to construct tree
    const tree = new MerkleTree(leaves, SHA256); // Construct tree
    const encryptedVerifier = SHA256(verifier);
    const newProof = tree.getProof(verifier);
    const result = tree.verify(newProof, encryptedVerifier, mroot);

    // console.log("RESULT = ", result);

    let provide = await cInstance.provideCredential(0, result, verifier, {from:accounts[2]});
    truffleAssert.eventEmitted(provide, "grantedAccess");

    // Once this step is done, we use API endpoints on the university's server to do another identity check
    
  });

  it('Disallow 3rd party to perform verification if not in tree', async() => {
    let req = await cInstance.verifyCredentials(0, {from:accounts[3]});
  
    let eventRes = req.logs[0].args;
    truffleAssert.eventEmitted(req, 'requestCredential');

    // console.log("MRoot = ", eventRes[2]);
    // console.log("Address = ", eventRes[1])
    // console.log("ID = ", eventRes[0]['words'][0]);

    let id = eventRes[0]['words'][0];
    let verifier = eventRes[1];
    let mroot = eventRes[2];

    // Calculate merkle root and compare
    // Get old tree --> Simulated
    const leaves = [accounts[4]].map(x => SHA256(x)); // Add leaves to construct tree
    const tree = new MerkleTree(leaves, SHA256); // Construct tree
    const encryptedVerifier = SHA256(verifier);
    const newProof = tree.getProof(verifier);
    const result = tree.verify(newProof, encryptedVerifier, mroot);

    // console.log("RESULT = ", result);

    let provide = cInstance.provideCredential(0, result, verifier, {from:accounts[2]});
    await truffleAssert.reverts(provide, "Invalid Access Rights");
    
  });

  it('Prevent off-chain tampering', async() => {
    let req = await cInstance.verifyCredentials(0, {from:accounts[3]});
  
    let eventRes = req.logs[0].args;
    truffleAssert.eventEmitted(req, 'requestCredential');

    // console.log("MRoot = ", eventRes[2]);
    // console.log("Address = ", eventRes[1])
    // console.log("ID = ", eventRes[0]['words'][0]);

    let id = eventRes[0]['words'][0];
    let verifier = eventRes[1];
    let mroot = eventRes[2];

    // Calculate merkle root and compare
    // Get old tree --> Simulated
    const leaves = [accounts[8]].map(x => SHA256(x)); // Add leaves to construct tree
    const tree = new MerkleTree(leaves, SHA256); // Construct tree
    const encryptedVerifier = SHA256(verifier);
    const newProof = tree.getProof(verifier);
    const result = tree.verify(newProof, encryptedVerifier, mroot);

    // console.log("RESULT = ", result);

    let provide = cInstance.provideCredential(0, result, verifier, {from:accounts[2]});
    await truffleAssert.reverts(provide, "Invalid Access Rights");
    
  });

  it('Allow institution to add company', async () => {
    let addCompany = await cInstance.addCompany(accounts[5], {from:accounts[1]});
    truffleAssert.eventEmitted(addCompany, "companyListed");

    let checkStatus = await cInstance.getCompanyStatus(accounts[5]);
    assert(checkStatus.valueOf(), true, "Company not added properly");
  });

  it('Check statistics working correctly - I', async() => {
    let stat = await cInstance.getCompanyStats(accounts[5]);
    assert(stat.valueOf(), 50, "Statistics Incorrect");
  });

  it('Allow second institution to attest to company', async() => {
    let addCompany = await cInstance.addCompany(accounts[5], {from:accounts[7]});
    truffleAssert.eventEmitted(addCompany, "companyAttested");

    let checkStatus = await cInstance.getCompanyStatus(accounts[5]);
    assert(checkStatus.valueOf(), true, "Company not added properly");

  });

  it('Check statistics working correctly - II', async() => {
    let stat = await cInstance.getCompanyStats(accounts[5]);
    assert(stat.valueOf(), 100, "Statistics Incorrect");
  });

  it('Allow company to issue credential', async ()=> {
    let o = accounts[2]; // Owner
    let p = "abcde"; // Pointer contents
    let issueCred = await cInstance.issueCompCred(o, p, {from:accounts[5]});
    truffleAssert.eventEmitted(issueCred, "credentialIssued");
  });

});
