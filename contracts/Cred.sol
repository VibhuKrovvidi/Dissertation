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

    struct compStats {
        uint256 companyID;
        address companyAddress;
        uint256 coverageNumber; // How many universities attest to company
        uint256 coveragePercentage; // % of total universities
    }

    uint256 universityNumber; // How many unis in system?
    uint256 companyNumber; // How many companies in system?

    mapping(uint256 => cred) credentials; // ID to credential struct
    mapping(address => bool) verifiedInstitution; //Check if institution is verified
    mapping(address => bool) verifiedCompany; //Check if company is verified
    mapping(uint256 => compStats) companyStatistics; // CompanyID to statistics for comp
    mapping(address => uint256) companyIDs; // Company Address to Company ID
    mapping(address => bool) admins; // Check if address is an admin
    mapping(uint256 => address) userCredentials; // CredentialID to owner mapping

    event institutionListed(address institution);
    event companyListed(address company);
    event credentialIssued(address candidate, uint256 id);
    event requestCredential(uint256 id, address verifier, string merkleroot);
    event updateAccess(uint256 id, address verifier);
    event addedAdmin(address admin);
    event grantedAccess(address verifier, string pointer);
    event addedAccess(uint256 id);
    event companyAttested(address company);
    event credentialDeactivated(uint256 id);

    constructor() public {
        ids = 0; // Set id as 0 initially
        admins[msg.sender] = true; //Admin is initator of this contract
        universityNumber = 0;
        companyNumber = 0;
    }

    // Allows any admin to add other admins
    function addAdmin(address admin) public {
        
        require(admins[msg.sender] == true, "Not Admin!");
        require(verifiedInstitution[admin] == true, "Only Universities can become Admins");
        admins[admin] = true;
        emit addedAdmin(admin);
    }

    // Allows admins to add institutions that can issue credentials
    function addInstitution(address inst) public {
        // Allow an institution to issue credentials
        require(admins[msg.sender] == true, "Not Admin!");
        verifiedInstitution[inst] = true;
        universityNumber = universityNumber + 1;
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
        credentials[ids] = newCred;
        emit credentialIssued(owner, ids);

        ids = ids + 1;
    }

    // Allows users to get a credential they own
    function getCredentialOwned(uint256 id) public view returns(string memory) {
        require(msg.sender == userCredentials[id], "Can't access credential");
        cred memory cr = credentials[id];
        return cr.pointer;
    }

    // Allows a 3rd party to request to verify credential
    function verifyCredentials(uint256 id) public {
        cred memory cr = credentials[id];
        emit requestCredential(id, msg.sender, cr.merkleroot);
        //Emits event to be seen by web3js
    }

    // Allows candidates to provide requested credential
    function provideCredential(uint256 id, bool access, address verifier) public returns(string memory) {
        cred memory cr = credentials[id];
        require(msg.sender == cr.owner, "Only owner can verify");
        require(access == true, "Invalid Access Rights");
        emit grantedAccess(verifier, cr.pointer); // Returns to be seen by web3
        return cr.pointer;
    }

    // Allows user to update access list to include another user
    function updateAccessList(uint256 id, string memory root) public {
        cred memory cr = credentials[id];
        require(msg.sender == cr.owner, "Only owners can change access");
        
        cred memory newCred = cred(
            cr.id,
            cr.issuer,
            msg.sender,
            cr.active,
            cr.pointer,
            root
        );

        credentials[id] = newCred;
        emit addedAccess(id);
    }

    // Allows admins to add a company that can issue credentials
    function addCompany(address comp) public {
        // Only institutions can add companies
        require(verifiedInstitution[msg.sender] == true, "Not a verified institution!");

        // If company is not in system, add it
        if(verifiedCompany[comp] == false) {

            verifiedCompany[comp] = true;
            companyIDs[comp] = companyNumber;
            
            compStats memory newComp = compStats(
                companyNumber,
                comp,
                1, // How many universities attest to company
                (1/universityNumber)*100
            );

            companyNumber = companyNumber + 1;
            
            // Add company stats entry
            companyStatistics[companyNumber] = newComp;

            emit companyListed(comp);

        } else {
            // Else update existing company stats
            compStats memory record = companyStatistics[companyIDs[comp]];
            compStats memory update = compStats(
                record.companyID,
                record.companyAddress,
                record.coverageNumber + 1,
                ((record.coverageNumber + 1) / universityNumber) * 100
            );

            companyStatistics[companyIDs[comp]] = update;
            emit companyAttested(comp);
        }

    }

    // Allows verified company to issue a company credential
    function issueCompCred(address owner, string memory pointer) public {
        require(verifiedCompany[msg.sender], "Not a verified company!");

        cred memory newCred = cred(
            ids,
            msg.sender,
            owner,
            true,
            pointer,
            ""
        );
        
        userCredentials[ids] = owner;
        credentials[ids] = newCred;
        emit credentialIssued(owner, ids);

        ids = ids + 1;
    }

    // Get company Stats
    function getCompanyStats(address comp) public view returns(uint256) {
        return companyStatistics[companyIDs[comp]].coveragePercentage;
    }

    function getInstitutionStatus(address institute) public view returns(bool) {
        return verifiedInstitution[institute];
    }

    function getCompanyStatus(address company) public view returns(bool) {
        return verifiedCompany[company];
    }

    function deactivateCredential(uint256 id) public {
        cred memory toDeactivate = credentials[id];
        require(msg.sender == toDeactivate.issuer, "Can't deactivate credential!");
        toDeactivate.active = false;
        credentials[id] = toDeactivate;
        emit credentialDeactivated(id);
    }
}
