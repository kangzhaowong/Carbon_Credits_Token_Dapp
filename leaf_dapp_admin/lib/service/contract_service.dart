import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/crypto.dart';
import '../constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

final _contractProvider = ChangeNotifierProvider((ref) => ContractService());

class ContractService extends ChangeNotifier {
  static AlwaysAliveProviderBase<ContractService> get provider =>
      _contractProvider;
  bool loading = true;

  var consoletext = "";

  late final Web3Client _web3client;
  late final DeployedContract _contract;
  late final EthereumAddress _contractAddress;
  late final String _abiCode;
  late Credentials _credentials;

  late final ContractFunction _difficulty;
  late final ContractFunction _newLeafCode;
  late final ContractFunction _addFunds;
  late final ContractFunction _modifyExchangeRate;
  late final ContractFunction _modifyDifficulty;
  late final ContractFunction _checkOwnerBalance;
  late final ContractFunction _withdrawOwnerBalance;
  late final ContractFunction _addPartnerCompany;
  late final ContractFunction _removePartnerCompany;
  late final ContractFunction _mint;
  late final ContractFunction _recieveMoney;
  late final ContractFunction _getCompanyAddresses;
  late final ContractFunction _getCompanyData;
  late final ContractFunction _getTokenBalance;

  late int difficulty;
  String qrcodetext = "";

  ContractService() {
    _initWeb3();
  }

  Future<void> _initWeb3() async {
    _web3client = Web3Client(Constants.RPC_URL, Client(), socketConnector: () {
      return IOWebSocketChannel.connect(Constants.WS_URL).cast<String>();
    });
    await _getAbi();
    await _getDeployedContract();
  }

  Future<void> _getAbi() async {
    final abifile = await rootBundle.loadString('src/contracts/Leaf.json');
    _abiCode = jsonEncode(jsonDecode(abifile));
    _contractAddress = EthereumAddress.fromHex(Constants.CONTRACT_ADDRESS);
  }

  getCredentials(String key) {
    _credentials = EthPrivateKey.fromHex(key);
  }

  Future<void> _getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "LeafContract"), _contractAddress);
    _difficulty = _contract.function("difficulty");
    _newLeafCode = _contract.function("newLeafCode");
    _addFunds = _contract.function("addFunds");
    _modifyExchangeRate = _contract.function("modifyExchangeRate");
    _modifyDifficulty = _contract.function("modifyDifficulty");
    _checkOwnerBalance = _contract.function("checkOwnerBalance");
    _withdrawOwnerBalance = _contract.function("withdrawBalance");
    _addPartnerCompany = _contract.function("addPartnerCompany");
    _removePartnerCompany = _contract.function("removePartnerCompany");
    _mint = _contract.function("mint");
    _recieveMoney = _contract.function("recieveMoney");
    _getCompanyAddresses = _contract.function("allCompanyAddresses");
    _getCompanyData = _contract.function("company_data");
    _getTokenBalance = _contract.function("balanceOf");
  }

  addToConsole(var info, var msg) {
    var msgstr = "$info";
    if (msg is List) {
      msgstr += "[";
      for (int i = 0; i < msg.length - 1; i++) {
        msgstr += msg[i] + ",";
      }
      msgstr += msg[msg.length - 1] + "]";
    } else {
      msgstr += (msg).toString();
    }
    consoletext += "$msgstr\n";
    notifyListeners();
  }

  generateLeafCode(var amount) async {
    assert(amount.length > 0);
    assert(int.parse(amount[0]) > 0);
    var difficulty = 0;
    await _web3client.call(
        contract: _contract, function: _difficulty, params: []).then((value) {
      difficulty = int.parse(value.first.toString());
      addToConsole("Difficulty: ", value[0]);
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
    if (difficulty > 0) {
      var idx = bytesToHex(keccakAscii(uuid.v4()), include0x: true);
      var code = bytesToHex(keccakAscii(uuid.v4()), include0x: true);
      var passwords = List.filled(difficulty, "");
      var passwordToSend = List.filled(difficulty, Uint8List(32));
      for (int i = 0; i < difficulty; i++) {
        passwords[i] =
            bytesToHex(keccakAscii(code + i.toString()), include0x: true);
        passwordToSend[i] = keccakAscii(code + i.toString());
      }
      await _web3client
          .sendTransaction(
              _credentials,
              Transaction.callContract(
                  contract: _contract,
                  function: _newLeafCode,
                  parameters: [
                    idx,
                    passwordToSend,
                    BigInt.from(int.parse(amount[0]))
                  ]),
              chainId: Constants.chainId)
          .then((txhash) => _web3client.getTransactionReceipt(txhash))
          .then((value) {
        addToConsole("Leaf Code Identifier: ", idx);
        addToConsole("Leaf Code: ", code);
        addToConsole("Leaf Code Passwords: ", passwords);
        qrcodetext = '$idx,$code';
        addToConsole("", "");
      }).onError((error, stackTrace) {
        addToConsole("Error: ", error);
        addToConsole("", "");
      });
    }
  }

  addFunds(var amount) async {
    assert(amount.length > 0);
    assert(int.parse(amount[0]) > 0);
    BigInt amountToSend =
        BigInt.from(double.parse(amount[0]) * 1000000000000000000);
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _addFunds,
                parameters: [],
                value: EtherAmount.fromBigInt(EtherUnit.wei, amountToSend)),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Funds Transfer Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  modifyExchangeRate(var rate) async {
    assert(rate.length > 0);
    assert(int.parse(rate[0]) > 0);
    BigInt newrate = BigInt.from(int.parse(rate[0]));
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _modifyExchangeRate,
                parameters: [newrate]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("New Rate Set", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  modifyDifficulty(var difficulty) async {
    assert(difficulty.length > 0);
    assert(int.parse(difficulty[0]) > 0);
    BigInt newDifficulty = BigInt.from(int.parse(difficulty[0]));
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _modifyDifficulty,
                parameters: [newDifficulty]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("New Difficulty Set", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  checkOwnerBalance() async {
    await _web3client.call(
        sender: _credentials.address,
        contract: _contract,
        function: _checkOwnerBalance,
        params: []).then((value) {
      addToConsole("Current Owner Balance: ", "${value[0]} Wei");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  withdrawOwnerBalance(var amount) async {
    assert(amount.length > 0);
    assert(int.parse(amount[0]) > 0);
    BigInt amountToWithdraw = BigInt.from(int.parse(amount[0]));
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _withdrawOwnerBalance,
                parameters: [amountToWithdraw]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Withdrawn Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  addPartnerCompany(var companydata) async {
    assert(companydata.length > 0);
    assert(int.parse(companydata[2]) > 0);
    BigInt exchangerate = BigInt.from(int.parse(companydata[2]));
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _addPartnerCompany,
                parameters: [
                  EthereumAddress.fromHex(companydata[0]),
                  companydata[1],
                  exchangerate
                ]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Adding Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  removePartnerCompany(var companyaddress) async {
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _removePartnerCompany,
                parameters: [EthereumAddress.fromHex(companyaddress[0])]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Remove Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  mint(var code) async {
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _mint,
                parameters: [code[0], code[1]]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Minting Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  recieveMoney(var recievemonydata) async {
    assert(int.parse(recievemonydata[1]) > 0);
    BigInt tokens = BigInt.from(int.parse(recievemonydata[1]));
    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _recieveMoney,
                parameters: [
                  EthereumAddress.fromHex(recievemonydata[0]),
                  tokens
                ]),
            chainId: Constants.chainId)
        .then((txhash) => _web3client.getTransactionReceipt(txhash))
        .then((value) {
      addToConsole("Transaction Successful", "");
      addToConsole("", "");
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
      addToConsole("", "");
    });
  }

  getAllCompanyData() async {
    List companiesAddresses = List.empty(growable: true);
    await _web3client.call(
        contract: _contract,
        function: _getCompanyAddresses,
        params: []).then((value) {
      companiesAddresses = value[0];
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
    });

    for (int i = 0; i < companiesAddresses.length; i++) {
      await _web3client.call(
          contract: _contract,
          function: _getCompanyData,
          params: [companiesAddresses[i]]).then((value) {
        addToConsole(
            "Company Data @${companiesAddresses[i]}: ", value.toString());
      }).onError((error, stackTrace) {
        addToConsole("Error: ", error);
      });
    }
    addToConsole("", "");
  }

  checkTokenBalance() async {
    await _web3client.call(
        contract: _contract,
        function: _getTokenBalance,
        params: [_credentials.address]).then((value) {
      addToConsole("Your Token Balance: ", "${value[0]} LEAF");
      addToConsole("", "");
    }).onError((error, stackTrace) => addToConsole("Error: ", error));
  }

  checkETHBalance() async {
    await _web3client.getBalance(_credentials.address).then((value) {
      addToConsole("Your ETH Balance: ", value);
      addToConsole("", "");
    }).onError((error, stackTrace) => addToConsole("Error: ", error));
  }
}
