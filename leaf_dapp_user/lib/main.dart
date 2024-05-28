import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:leafdapp_user/contractservice.dart';
import 'package:web3dart/web3dart.dart';

var contractservice = ContractService();
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      // debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final TextEditingController keyInputController = TextEditingController();

  scrollDown() {
    setState(() {
      _consoleScrollController.animateTo(
          _consoleScrollController.position.maxScrollExtent + 1000,
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeInOut);
    });
  }

  parameterStringSplitter(var str) {
    return str.split(",");
  }

  void __getTokenBalance() async {
    await ref.read(ContractService.provider).checkTokenBalance();
    scrollDown();
  }

  void __getEthBalance() async {
    await ref.read(ContractService.provider).checkETHBalance();
    scrollDown();
  }

  void __scan(String? code) async {
    if (code != null) {
      await ref
          .read(ContractService.provider)
          .mint(parameterStringSplitter(code));
      scrollDown();
    }
  }

  __recieveMoney(EthereumAddress companyAddress) async {
    var amount = "10";
    await ref
        .read(ContractService.provider)
        .recieveMoney([companyAddress.toString(), amount]);
  }

  __showCompanyData() async {
    return await ref.read(ContractService.provider).getAllCompanyData();
  }

  __getCompanyFunds() async {
    return await ref.read(ContractService.provider).getAllCompanyFunds();
  }

  __getStoredKey() async {
    return await ref.read(ContractService.provider).getStoredKey();
  }

  __setStoredKey(String newKey) async {
    await ref.read(ContractService.provider).setStoredKey(newKey);
  }

  void __tradeTokens(context) async {
    var companyData = await __showCompanyData();
    var companyFunds = await __getCompanyFunds();
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
              child: CustomScrollView(slivers: [
            SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
              return TextButton(
                  onPressed: () async {
                    await __recieveMoney(companyData[index][2]);
                    // Navigator.pop(context);
                    ref.read(ContractService.provider).consoletext;
                    scrollDown();
                  },
                  child: Text(
                      "${companyData[index][0]}(Funds Left:${companyFunds[index]}): 1 LEAF to ${companyData[index][1]} Wei"));
            }, childCount: companyData.length))
          ]));
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 148, 171, 111),
          toolbarHeight: 60,
        ),
        body: Column(children: <Widget>[
          Expanded(
              flex: 1,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    controller: _consoleScrollController,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      child: SelectableText(
                          ref.read(ContractService.provider).consoletext,
                          style: const TextStyle(height: 1, wordSpacing: 1)),
                    )),
              )),
          SizedBox(
              height: 300,
              child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.count(
                      crossAxisCount: 4,
                      mainAxisSpacing: 20,
                      crossAxisSpacing: 20,
                      children: <Widget>[
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: __getTokenBalance,
                            tooltip: 'Get Leaf Token Balance',
                            child: const Icon(Icons.wallet)),
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: __getEthBalance,
                            tooltip: 'Get ETH Balance',
                            child: const Icon(Icons.paid)),
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (dialogContext) {
                                    return Dialog(
                                      child: MobileScanner(
                                          controller: MobileScannerController(
                                            detectionSpeed:
                                                DetectionSpeed.normal,
                                            facing: CameraFacing.back,
                                          ),
                                          onDetect: (capture) {
                                            Navigator.pop(dialogContext);
                                            __scan(
                                                capture.barcodes[0].rawValue);
                                          }),
                                    );
                                  });
                            },
                            tooltip: 'Scan Permit',
                            child: const Icon(Icons.eco)),
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              __tradeTokens(context);
                            },
                            tooltip: 'Trade Tokens',
                            child: const Icon(Icons.currency_exchange)),
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: __getStoredKey,
                            tooltip: 'Get Stored Key',
                            child: const Icon(Icons.key)),
                        FloatingActionButton(
                            heroTag: null,
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (dialogContext) => AlertDialog(
                                        title: const Text('Enter Key'),
                                        content: TextField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            controller: keyInputController),
                                        actions: <Widget>[
                                          TextButton(
                                              onPressed: () {
                                                __setStoredKey(
                                                    keyInputController.text);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Ok')),
                                          TextButton(
                                            onPressed: () => Navigator.pop(
                                                context, 'Cancel'),
                                            child: const Text('Cancel'),
                                          )
                                        ],
                                      ));
                            },
                            tooltip: 'Set Stored Key',
                            child: const Icon(Icons.vpn_key)),
                      ])))
        ]));
  }
}
