pragma solidity >=0.4.22 <0.6.0;


contract Course {
    // Core 
    address public manager;
    bytes32 public data;
    bytes32 public course_id;
    mapping(address => string) public class;
    mapping(bytes32 => Module) public modules;
    uint256 public members;
    uint256 public current;
    
    // Module
    struct Module {
        address[] instructors;
        bytes32 id;
        bytes32 ipfs;
    }
    
    // Certification data models
    struct Certificate {
        string id;
        bytes32 ipfs;
        address certified; 
    }
    mapping(address => Certificate) public honors;
    
    
    /// Create a new course with certificate corresponding to the module
    constructor(bytes32 id, bytes32 ipfs, uint256 limit) public {
        manager = msg.sender;
        data = ipfs;
        course_id = id;
        members = limit; // set limit for each course season
    }


    // Register a learner in the course
    function register(address learner) public {
        require(msg.sender == manager && current <= members);
        class[learner] = "registered";
        current += 1;
        emit Registered(learner, course_id, current);
    }
    
    function deregister(address learner) public {
        require(msg.sender == manager);
        delete class[learner];
        current -= 1;
        emit Deregistered(learner, course_id, current);
    }
    
    function certify(address learner, bytes32 id) public {
        require(msg.sender == manager && keccak256(abi.encodePacked(class[learner])) == keccak256(abi.encodePacked("registered")));
        string memory certificate_id = string(abi.encodePacked(course_id, "-", id));
        class[learner] = "certified";
        honors[learner] = Certificate(certificate_id, data, learner);
        emit Certified(learner, course_id);
    }
    
    
    function addModule(bytes32 module_id, bytes32 ipfs) public {
        require(msg.sender == manager);
        // 1 for the manager
        address[] memory instructors = new address[](members + 1);
        modules[module_id] = Module(instructors, module_id, ipfs);
        emit ModuleAdded(manager, module_id);
    }
    
    function removeModule(bytes32 module_id) public {
        require(msg.sender == manager);
        delete modules[module_id];
        emit ModuleRemoved(manager, module_id);
    }
    
    
    function isInstructor(address instructor, bytes32 module_id) public view returns (bool result) {
        Module memory module = modules[module_id];
        address[] memory instructors = module.instructors;
        uint256 arrayLength = instructors.length;
        bool found=false;
        for (uint i=0; i<arrayLength; i++) {
            if(instructors[i]==instructor){
                found=true;
                break;
            }
        }
        if(!found){
            return found;
        }
    }
    
    function setInstructor(address learner, bytes32 module_id) public {
        require(msg.sender == manager || isInstructor(msg.sender, module_id));
        modules[module_id].instructors.push(learner);
        emit SetInstructor(learner, module_id);
    }
    
    function changeManager(address newManager) public {
        require(msg.sender == manager);
        emit NewManager(manager, newManager);
        manager = newManager;
    }
    
    
    // Events
    event Registered(address learner, bytes32 course_id, uint256 current);
    event Deregistered(address learner, bytes32 course_id, uint256 current);
    event SetInstructor(address instructor, bytes32 module_id);
    event Certified(address learner, bytes32 course);
    event ModuleAdded(address manager, bytes32 module_id);
    event ModuleRemoved(address manager, bytes32 module_id);
    event NewManager(address previousManager, address newManager);
}



