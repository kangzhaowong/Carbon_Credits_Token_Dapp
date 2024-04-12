// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.8.25;

import "@openzeppelin/contracts@4.9.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.9.0/access/AccessControl.sol";

contract LeafContract is ERC20, AccessControl {
    constructor(address defaultAdmin) ERC20("Leaf", "LEAF") {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
    }

    bytes32 public constant PARTNER_COMPANY_ROLE =
        keccak256("PARTNER_COMPANY_ROLE");
    uint256 public difficulty = 2;
    uint256 private inverse_royalty_percent = 10; // royalthy = 1/inverse_royalty_percent

    struct CompanyData {
        string company_name;
        uint256 exchange_rate;
    }

    address[] public company_addresses;
    mapping(address => uint256) public company_funds;
    mapping(address => CompanyData) public company_data;
    mapping(string => uint256) public leaf_codes;
    mapping(string => bytes32[]) public leaf_answers;

    function allCompanyAddresses() public view returns (address[] memory) {
        return company_addresses;
    }

    //User can mint and send recieve eth
    function mint(
        string memory _idx,
        string memory _code
    ) public returns (bool) {
        require(
            !hasRole(PARTNER_COMPANY_ROLE, msg.sender),
            "INVALID PERMISSIONS"
        );
        require(leaf_codes[_idx] != 0, "INVALID CODE");
        require(leaf_answers[_idx].length != 0, "INVALID CODE");
        for (uint256 i = 0; i < leaf_answers[_idx].length; i++) {
            require(
                keccak256(abi.encodePacked(_code, Strings.toString(i))) ==
                    leaf_answers[_idx][i],
                "INVALID CODE"
            );
        }
        _mint(msg.sender, leaf_codes[_idx]);
        delete leaf_answers[_idx];
        delete leaf_codes[_idx];
        return true;
    }

    function recieveMoney(
        address _company_address,
        uint256 _tokens
    ) public payable returns (uint256) {
        require(balanceOf(msg.sender) >= _tokens, "INSUFFICIENT TOKENS");
        require(
            !hasRole(PARTNER_COMPANY_ROLE, msg.sender),
            "INVALID PERMISSIONS"
        );
        require(
            _tokens *
                company_data[_company_address].exchange_rate +
                (_tokens * company_data[_company_address].exchange_rate) /
                inverse_royalty_percent <=
                company_funds[_company_address],
            "INSUFFICIENT FUNDS"
        );
        transfer(_company_address, _tokens);
        uint256 amount = _tokens * company_data[_company_address].exchange_rate;
        uint256 royalty_amount = (_tokens *
            company_data[_company_address].exchange_rate) /
            inverse_royalty_percent;
        company_funds[_company_address] -= (amount + royalty_amount);
        payable(msg.sender).transfer(amount);
        company_funds[tx.origin] += royalty_amount;
        return amount;
    }

    //Partner companies can add money, modify their exchange rates, and upload leaf code
    function addFunds() public payable returns (bool) {
        require(
            hasRole(PARTNER_COMPANY_ROLE, msg.sender),
            "INVALID PERMISSIONS"
        );
        company_funds[msg.sender] += msg.value;
        return true;
    }

    function modifyExchangeRate(uint256 _rate) public returns (bool) {
        require(
            hasRole(PARTNER_COMPANY_ROLE, msg.sender),
            "INVALID PERMISSIONS"
        );
        company_data[msg.sender].exchange_rate = _rate;
        return true;
    }

    function newLeafCode(
        string memory _idx,
        bytes32[] memory _answers,
        uint256 _amount
    ) public returns (bool) {
        require(
            hasRole(PARTNER_COMPANY_ROLE, msg.sender),
            "INVALID PERMISSIONS"
        );
        leaf_codes[_idx] = _amount;
        leaf_answers[_idx] = _answers;
        return true;
    }

    //Administrator can add or remove companies, modify difficulty, check or withdraw balance
    function modifyDifficulty(uint256 _difficulty) public returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "INVALID PERMISSIONS");
        difficulty = _difficulty;
        return true;
    }

    function checkOwnerBalance() public view returns (int256) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "INVALID PERMISSIONS");
        int256 leftover = int256(address(this).balance);
        for (uint256 i = 0; i < company_addresses.length; ++i) {
            leftover -= int256(company_funds[company_addresses[i]]);
        }
        return leftover;
    }

    function withdrawBalance(uint256 _amount) public returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "INVALID PERMISSIONS");
        require(_amount < address(this).balance, "NOT ENOUGH FUNDS");
        require(int(_amount) < checkOwnerBalance(), "NOT ENOUGH FUNDS");
        payable(tx.origin).transfer(_amount);
        return true;
    }

    function addPartnerCompany(
        address _company_address,
        string memory _company_name,
        uint256 _rate
    ) public returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "INVALID PERMISSIONS");
        _grantRole(PARTNER_COMPANY_ROLE, _company_address);
        company_data[_company_address] = CompanyData({
            company_name: _company_name,
            exchange_rate: _rate
        });
        company_addresses.push(_company_address);
        return true;
    }

    function removePartnerCompany(
        address _company_address
    ) public returns (bool) {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "INVALID PERMISSIONS");
        _revokeRole(PARTNER_COMPANY_ROLE, _company_address);
        for (uint256 i = 0; i < company_addresses.length; ++i) {
            if (_company_address == company_addresses[i]) {
                company_addresses[i] ==
                    company_addresses[company_addresses.length - 1];
                company_addresses.pop();
                break;
            }
        }
        delete company_data[_company_address];
        delete company_funds[_company_address];
        return true;
    }
}
