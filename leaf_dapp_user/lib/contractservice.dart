import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:uuid/uuid.dart';
import 'package:leafdapp_user/constants.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

var uuid = const Uuid();

final _contractProvider = ChangeNotifierProvider((ref) => ContractService());

class ContractService extends ChangeNotifier {
  static AlwaysAliveProviderBase<ContractService> get provider =>
      _contractProvider;
  bool loading = true;
  final _storage = const FlutterSecureStorage();
  bool noKeyFlag = true;

  var consoletext = "";

  late final Web3Client _web3client;
  late final DeployedContract _contract;
  late final EthereumAddress _contractAddress;
  late final String _abiCode;
  // Credentials _credentials = EthPrivateKey.fromHex(Constants.myPrivateKey);
  late Credentials _credentials;

  late final ContractFunction _mint;
  late final ContractFunction _recieveMoney;
  late final ContractFunction _getCompanyAddresses;
  late final ContractFunction _getCompanyData;
  late final ContractFunction _getTokenBalance;
  late final ContractFunction _getCompanyFunds;

  late int difficulty;
  String qrcodetext = "";

  ContractService() {
    getStoredKey();
    _initWeb3();
  }

  getStoredKey() async {
    String? storedPrivateKey = await _storage.read(key: "PRIVATEKEY");
    if (storedPrivateKey != null) {
      addToConsole("Key: ", storedPrivateKey);
      _credentials = EthPrivateKey.fromHex(storedPrivateKey);
      noKeyFlag = false;
    } else {
      addToConsole("Key: ", "Null");
      noKeyFlag = true;
    }
    notifyListeners();
  }

  setStoredKey(String newKey) async {
    if (newKey == "") {
      await _storage.delete(key: "PRIVATEKEY");
    } else {
      await _storage.write(key: "PRIVATEKEY", value: newKey);
    }
    await getStoredKey();
    notifyListeners();
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

  Future<void> _getDeployedContract() async {
    _contract = DeployedContract(
        ContractAbi.fromJson(_abiCode, "LeafContract"), _contractAddress);
    _mint = _contract.function("usePermit");
    _recieveMoney = _contract.function("exchangeTokens");
    _getCompanyAddresses = _contract.function("allCompanyAddresses");
    _getCompanyData = _contract.function("company_data");
    _getTokenBalance = _contract.function("balanceOf");
    _getCompanyFunds = _contract.function("company_funds");
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

  mint(List code) async {
    addToConsole("Idx: ", code[0]);
    addToConsole("Code: ", code[1]);

    await _web3client
        .sendTransaction(
            _credentials,
            Transaction.callContract(
                contract: _contract,
                function: _mint,
                parameters: [code[0].toString(), code[1].toString()]),
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
    addToConsole("Chosen Data", recievemonydata);
    if (int.parse(recievemonydata[1]) > 0) {
      await _web3client
          .sendTransaction(
              _credentials,
              Transaction.callContract(
                  contract: _contract,
                  function: _recieveMoney,
                  parameters: [
                    EthereumAddress.fromHex(recievemonydata[0]),
                    BigInt.from(int.parse(recievemonydata[1]))
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

    List companyData = List.empty(growable: true);
    for (int i = 0; i < companiesAddresses.length; i++) {
      await _web3client.call(
          contract: _contract,
          function: _getCompanyData,
          params: [companiesAddresses[i]]).then((value) {
        var temp = value.toList();
        temp.add(companiesAddresses[i]);
        companyData.add(temp);
        // addToConsole(
        //     "Company Data @${companiesAddresses[i]}: ", value.toString());
      }).onError((error, stackTrace) {
        addToConsole("Error: ", error);
      });
    }
    // addToConsole("", "");
    return companyData;
  }

  getAllCompanyFunds() async {
    List companiesAddresses = List.empty(growable: true);
    await _web3client.call(
        contract: _contract,
        function: _getCompanyAddresses,
        params: []).then((value) {
      companiesAddresses = value[0];
    }).onError((error, stackTrace) {
      addToConsole("Error: ", error);
    });

    List companyFunds = List.empty(growable: true);
    for (int i = 0; i < companiesAddresses.length; i++) {
      await _web3client.call(
          contract: _contract,
          function: _getCompanyFunds,
          params: [companiesAddresses[i]]).then((value) {
        var temp = "${value.first} Wei";
        companyFunds.add(temp);
      }).onError((error, stackTrace) {
        addToConsole("Error: ", error);
      });
    }
    // addToConsole("", "");
    return companyFunds;
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
      addToConsole("", value);
      addToConsole("", "");
    }).onError((error, stackTrace) => addToConsole("Error: ", error));
  }
}
