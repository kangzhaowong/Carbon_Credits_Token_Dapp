import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:leafdapp_user/contractservice.dart';
import 'package:web3dart/web3dart.dart';
import 'dart:async';

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
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    HomeScreen(
      title: 'HomeScreen',
    ),
    ExchangeScreen(
      title: 'ExchangeScreen',
    ),
    ProfileScreen(
      title: 'ProfileScreen',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.green,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.grey),
            activeIcon: Icon(Icons.home, color: Colors.green),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_exchange, color: Colors.grey),
            activeIcon: Icon(Icons.currency_exchange, color: Colors.green),
            label: 'Exchange',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.grey),
            activeIcon: Icon(Icons.person, color: Colors.green),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String ethBalance = "0";
  String tokenBalance = "0";
  late Timer balanceTimer;

  checkBalances() {
    contractservice.checkETHBalance().then((value) {
      setState(() {
        ethBalance = value;
      });
    });
    contractservice.checkTokenBalance().then((value) {
      setState(() {
        tokenBalance = value;
      });
    });
  }

  void __scan(String? code) async {
    if (code != null) {
      await ref.read(ContractService.provider).mint(code.split(","));
    }
  }

  @override
  initState() {
    super.initState();
    checkBalances();
    balanceTimer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => checkBalances());
  }

  @override
  void dispose() {
    balanceTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/img/Carbon footprint NFT_1.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 50, 10, 0),
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: FloatingActionButton(
                        backgroundColor: const Color.fromRGBO(139, 171, 111, 1),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                    content: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Image.asset('assets/img/Page 1.jpg',
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 20),
                                      Image.asset('assets/img/Page 2.jpg',
                                          fit: BoxFit.fill),
                                      const SizedBox(height: 20),
                                      Image.asset('assets/img/Page 3.jpg',
                                          fit: BoxFit.fill)
                                    ],
                                  ),
                                ));
                              });
                        },
                        child: const Icon(Icons.question_mark,
                            color: Colors.white, size: 20)),
                  ))),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text("Current Balances",
                style: TextStyle(fontFamily: "Gotham")),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/leaf.png",
                  width: 20,
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "$tokenBalance LEAF",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gotham"),
                    ))
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/img/eth.png",
                  width: 20,
                ),
                Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      "$ethBalance ETH",
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Gotham"),
                    ))
              ],
            ),
            const SizedBox(height: 100)
          ])
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (dialogContext) {
                return Dialog(
                  child: MobileScanner(
                      controller: MobileScannerController(
                        detectionSpeed: DetectionSpeed.normal,
                        facing: CameraFacing.back,
                      ),
                      onDetect: (capture) {
                        Navigator.pop(dialogContext);
                        __scan(capture.barcodes[0].rawValue);
                      }),
                );
              });
        },
        backgroundColor: const Color.fromARGB(255, 100, 142, 56),
        child: const Icon(
          Icons.qr_code_scanner_sharp,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ExchangeScreen extends ConsumerStatefulWidget {
  const ExchangeScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<ExchangeScreen> createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends ConsumerState<ExchangeScreen> {
  final TextEditingController keyInputController = TextEditingController();
  final TextEditingController amountInputController = TextEditingController();
  late Timer balanceTimer;
  late List companyData = [];

  getCompanyData() async {
    List allCompanyData = await contractservice.getAllCompanyData();
    List updatedCompanyData = [];
    for (var i = 0; i < allCompanyData.length; i++) {
      if (allCompanyData[i][3] >= BigInt.parse("5000000000000000000") &&
          allCompanyData[i][0]
              .toLowerCase()
              .contains(keyInputController.text.toLowerCase())) {
        updatedCompanyData.add(allCompanyData[i]);
      }
    }
    setState(() {
      companyData = updatedCompanyData;
    });
  }

  __recieveMoney(EthereumAddress companyAddress, String amount) async {
    if (int.tryParse(amount) == null) {
      amount = "0";
    }
    await ref
        .read(ContractService.provider)
        .recieveMoney([companyAddress.toString(), amount]);
  }

  @override
  initState() {
    super.initState();
    getCompanyData();
    balanceTimer = Timer.periodic(
        const Duration(seconds: 15), (Timer t) => getCompanyData());
  }

  @override
  void dispose() {
    balanceTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 251, 246, 241),
        body: Column(
          children: [
            const SizedBox(height: 20),
            const Text("Token Exchange",
                style: TextStyle(
                    fontFamily: 'Gotham',
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                  controller: keyInputController,
                  onChanged: (value) => getCompanyData(),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search by Company Name')),
            ),
            Padding(
                padding: const EdgeInsets.all(10),
                child: SizedBox(
                    height: 400,
                    width: 400,
                    child: ListView.builder(
                      itemCount: companyData.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                                child: Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
                              child: ListTile(
                                  title: Text(
                                    companyData[index][0],
                                    style: const TextStyle(
                                        fontFamily: 'Gotham',
                                        color: Colors.white),
                                  ),
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  tileColor:
                                      const Color.fromARGB(255, 139, 171, 111),
                                  subtitle: Text(
                                    "Exchange ${companyData[index][1]} Leaf for 1 ETH",
                                    style: const TextStyle(
                                        fontFamily: 'Gotham',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white),
                                  )),
                            )),
                            Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 0, 10, 10),
                                child: SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: FloatingActionButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (dialogContext) =>
                                                  AlertDialog(
                                                    title: const Text(
                                                        'Enter Amount'),
                                                    content: TextField(
                                                        decoration:
                                                            const InputDecoration(
                                                          border:
                                                              OutlineInputBorder(),
                                                        ),
                                                        controller:
                                                            amountInputController),
                                                    actions: <Widget>[
                                                      TextButton(
                                                          onPressed: () {
                                                            __recieveMoney(
                                                                companyData[
                                                                    index][2],
                                                                amountInputController
                                                                    .text);
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child:
                                                              const Text('Ok')),
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.pop(
                                                                context,
                                                                'Cancel'),
                                                        child: const Text(
                                                            'Cancel'),
                                                      )
                                                    ],
                                                  ));
                                        },
                                        backgroundColor: const Color.fromARGB(
                                            255, 100, 142, 56),
                                        child: const Icon(
                                            Icons.currency_exchange,
                                            color: Colors.white))))
                          ],
                        );
                      },
                    )))
          ],
        ));
  }
}

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key, required this.title});
  final String title;

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final TextEditingController keyInputController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: <Widget>[
      Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/img/Carbon footprint NFT_2.png"),
            fit: BoxFit.cover,
          ),
        ),
      ),
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const SizedBox(
          height: 300,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          FloatingActionButton.extended(
              label: const Text(
                'Connect Account',
                style: TextStyle(color: Colors.white, fontFamily: 'Gotham'),
              ),
              icon: const Icon(
                Icons.key,
                color: Colors.white,
              ),
              backgroundColor: const Color.fromARGB(255, 100, 142, 56),
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
                                  contractservice
                                      .setStoredKey(keyInputController.text);
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok')),
                            TextButton(
                              onPressed: () => Navigator.pop(context, 'Cancel'),
                              child: const Text('Cancel'),
                            )
                          ],
                        ));
              })
        ]),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
                label: const Text('Disconnect Account',
                    style:
                        TextStyle(color: Colors.white, fontFamily: 'Gotham')),
                icon: const Icon(
                  Icons.key_off,
                  color: Colors.white,
                ),
                backgroundColor: const Color.fromARGB(255, 100, 142, 56),
                heroTag: null,
                onPressed: () {
                  contractservice.setStoredKey("");
                })
          ],
        )
      ])
    ]));
  }
}
