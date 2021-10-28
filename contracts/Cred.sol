pragma solidity ^0.5.0;

contract Cred {
    uint256 ids; // How many total ids are in circulation

    struct cred {
        uint256 id; // Unique id
        address issuer; // Issuer address
        address owner; // Owner account address
        bool active; // Status of credential
        string pointer; // Pointer to database housing underlying credential
        string merkleroot; // Root of merkle tree that contains access addresses
    }

    mapping(uint256 => cred) EduCredentials; // ID to credential struct
    mapping(address => bool) verifiedInstitution;
    mapping(address => bool) admins;
    mapping(uint256 => address) userCredentials;

    event institutionListed(address institution);
    event credentialIssued(address candidate);
    event requestCredential(uint256 id, address verifier, string merkleroot);
    event updateAccess(uint256 id, address verifier);
    event addedAdmin(address admin);
    event grantedAccess(address verifier, string pointer);
    event addedAccess(uint256 id);

    constructor() public {
        ids = 0; // Set id as 0 initially
        admins[msg.sender] = true; //Admin is initator of this contract
    }

    // Allows any admin to add other admins
    function addAdmin(address admin) public {
        require(admins[msg.sender] == true, "Not Admin!");
        admins[admin] = true;
        emit addedAdmin(admin);
    }

    // Allows admins to add institutions that can issue credentials
    function addInstitution(address inst) public {
        // Allow an institution to issue credentials
        require(admins[msg.sender] == true, "Not Admin!");
        verifiedInstitution[inst] = true;
        emit institutionListed(inst);
    }

    // Allows verified institution to issue an educational credential
    function issueEduCred(address owner, string memory pointer) public {
        require(verifiedInstitution[msg.sender], "Not a verified institution!");

        cred memory newCred = cred(
            ids,
            msg.sender,
            owner,
            true,
            pointer,
            ""
        );
        userCredentials[ids] = owner;
        EduCredentials[ids] = newCred;
        emit credentialIssued(owner);

        ids = ids + 1;
    }

    // Allows users to see if they own a credential
    function getCredentialOwner(uint256 id) public view returns(string memory) {
        require(msg.sender == userCredentials[id], "Can't access credential");
        cred memory cr = EduCredentials[id];
        return cr.pointer;
    }

    // Allows a 3rd party to request to verify credential
    function verifyCredentials(uint256 id) public {
        cred memory cr = EduCredentials[id];
        emit requestCredential(id, msg.sender, cr.merkleroot);
        //Emits event to be seen by web3js
    }

    // Allows candidates to provide requested credential
    function provideCredential(uint256 id, bool access, address verifier) public returns(string memory) {
        cred memory cr = EduCredentials[id];
        require(msg.sender == cr.owner, "Only owner can verify");
        require(access == true, "Invalid Access Rights");
        emit grantedAccess(verifier, cr.pointer); // Returns to be seen by web3. Web3 can then check and provide the pointer to the verifier
        return cr.pointer;
    }

    // Allows user to update access list to include another user
    function updateAccessList(uint256 id, string memory root) public {
        cred memory cr = EduCredentials[id];
        require(msg.sender == cr.owner, "Only owners can change access");
        
        cred memory newCred = cred(
            cr.id,
            cr.issuer,
            msg.sender,
            cr.active,
            cr.pointer,
            root
        );

        EduCredentials[id] = newCred;
        emit addedAccess(id);
    }

}
