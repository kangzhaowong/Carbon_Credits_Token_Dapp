import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';
import '/service/contract_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'constants.dart';

var constants = Constants();
var contractservice = ContractService();

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Leaf dApp Company Control',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Leaf dApp Company Control'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final ScrollController _consoleScrollController = ScrollController();
  final ParameterTextController = TextEditingController();

  String consoleText = "";

  parameterStringSplitter(var str) {
    return str.split(RegExp(r'(?![^)(]*\([^)(]*?\)\)),(?![^\[]*\])'));
  }

  scrollDown() {
    setState(() {
      _consoleScrollController.animateTo(
          _consoleScrollController.position.maxScrollExtent + 1000,
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut);
    });
  }

  void __generateLeafCode() async {
    await ref.read(ContractService.provider).generateLeafCode(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
    displayQR();
  }

  void __addFunds() async {
    await ref
        .read(ContractService.provider)
        .addFunds(parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __modifyExchangeRate() async {
    await ref.read(ContractService.provider).modifyExchangeRate(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __modifyDifficulty() async {
    await ref.read(ContractService.provider).modifyDifficulty(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __checkOwnerBalance() async {
    await ref.read(ContractService.provider).checkOwnerBalance();
    scrollDown();
  }

  void __withdrawOwnerBalance() async {
    await ref.read(ContractService.provider).withdrawOwnerBalance(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __addPartnerCompany() async {
    await ref.read(ContractService.provider).addPartnerCompany(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __removePartnerCompany() async {
    await ref.read(ContractService.provider).removePartnerCompany(
        parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __mint() async {
    await ref
        .read(ContractService.provider)
        .mint(parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __recieveMoney() async {
    await ref
        .read(ContractService.provider)
        .recieveMoney(parameterStringSplitter(ParameterTextController.text));
    scrollDown();
  }

  void __allCompanyData() async {
    await ref.read(ContractService.provider).getAllCompanyData();
    scrollDown();
  }

  void __allCompanyFunds() async {
    await ref.read(ContractService.provider).getAllCompanyFunds();
    scrollDown();
  }

  void __checkTokenBalance() async {
    await ref.read(ContractService.provider).checkTokenBalance();
    scrollDown();
  }

  void __checkETHBalance() async {
    await ref.read(ContractService.provider).checkETHBalance();
    scrollDown();
  }

  void displayQR() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return Dialog(
              child: QrImageView(
            data: ref.read(ContractService.provider).qrcodetext,
            errorStateBuilder: (context, error) {
              return const Center(
                child: Text(
                  'Uh oh! Something went wrong...',
                  textAlign: TextAlign.center,
                ),
              );
            },
          ));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Row(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: DropdownMenu(
                      label: const Text("Select account to use."),
                      dropdownMenuEntries: dropDown(),
                      initialSelection: dropDown()[0],
                      onSelected: (value) => {
                            ref
                                .read(ContractService.provider)
                                .getCredentials(value)
                          }),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  child: SizedBox(
                      width: 500,
                      child: TextFormField(
                        autovalidateMode: AutovalidateMode.always,
                        controller: ParameterTextController,
                        decoration: const InputDecoration(
                            hintText: "Enter parameters seperated by a comma",
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    style: BorderStyle.solid,
                                    strokeAlign:
                                        BorderSide.strokeAlignOutside))),
                      )),
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                    child: SizedBox(
                      height: 400,
                      width: 500,
                      child: GridView.count(
                          crossAxisCount: 5,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20,
                          children: [
                            FloatingActionButton(
                              onPressed: __generateLeafCode,
                              tooltip: 'New Leaf Code',
                              child: const Icon(Icons.energy_savings_leaf),
                            ),
                            FloatingActionButton(
                              onPressed: __addFunds,
                              tooltip: 'Add Funds',
                              child: const Icon(Icons.money),
                            ),
                            FloatingActionButton(
                              onPressed: __modifyExchangeRate,
                              tooltip: 'Modify Rate',
                              child: const Icon(Icons.trending_up),
                            ),
                            FloatingActionButton(
                              onPressed: __modifyDifficulty,
                              tooltip: 'Change Difficulty',
                              child: const Icon(Icons.landscape),
                            ),
                            FloatingActionButton(
                              onPressed: __checkOwnerBalance,
                              tooltip: 'Check Owner Balance',
                              child: const Icon(Icons.account_balance),
                            ),
                            FloatingActionButton(
                              onPressed: __withdrawOwnerBalance,
                              tooltip: 'Withdraw Owner Balance',
                              child: const Icon(Icons.output),
                            ),
                            FloatingActionButton(
                              onPressed: __addPartnerCompany,
                              tooltip: 'Add Partner Company',
                              child: const Icon(Icons.person_add),
                            ),
                            FloatingActionButton(
                              onPressed: __removePartnerCompany,
                              tooltip: 'Remove Partner Company',
                              child: const Icon(Icons.person_remove),
                            ),
                            FloatingActionButton(
                              onPressed: __mint,
                              tooltip: 'Mint',
                              child: const Icon(Icons.currency_bitcoin),
                            ),
                            FloatingActionButton(
                              onPressed: __recieveMoney,
                              tooltip: 'Transact Tokens',
                              child: const Icon(Icons.currency_exchange),
                            ),
                            FloatingActionButton(
                              onPressed: __allCompanyData,
                              tooltip: 'Get All Company Data',
                              child: const Icon(Icons.insert_chart),
                            ),
                            FloatingActionButton(
                              onPressed: __allCompanyFunds,
                              tooltip: 'Get All Company Funds',
                              child: const Icon(Icons.assured_workload),
                            ),
                            FloatingActionButton(
                                onPressed: __checkTokenBalance,
                                tooltip: 'Check Token Balance',
                                child:
                                    const Icon(Icons.account_balance_wallet)),
                            FloatingActionButton(
                                onPressed: __checkETHBalance,
                                tooltip: 'Check ETH Balance',
                                child: const Icon(Icons.savings)),
                          ]),
                    ))
              ],
            ),
            Expanded(
                flex: 1,
                child: Container(
                  color: Colors.black,
                  height: MediaQuery.of(context).size.height,
                  child: SingleChildScrollView(
                      controller: _consoleScrollController,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                        child: SelectableText(
                            ref.read(ContractService.provider).consoletext,
                            style: const TextStyle(
                                color: Colors.white,
                                height: 1,
                                wordSpacing: 1)),
                      )),
                ))
          ],
        ));
  }

  List<DropdownMenuEntry> dropDown() {
    List<DropdownMenuEntry<String>> dropDownItems = [];
    for (int i = 0; i < constants.ALL_PRIVATE_KEYS.length; i++) {
      var newItem = DropdownMenuEntry(
        value: constants.ALL_PRIVATE_KEYS[i],
        label: EthPrivateKey.fromHex(constants.ALL_PRIVATE_KEYS[i])
            .address
            .toString(),
      );
      dropDownItems.add(newItem);
    }
    return dropDownItems;
  }
}
