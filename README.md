# Carbon_Credits_Token_Dapp
Climate change is a global emergency that goes beyond national borders. To tackle climate change and its negative impacts, world leaders set the Paris Agreement which includes commitments from all countries to reduce their emissions and work together to adapt to the impacts of climate change, and calls on countries to strengthen their commitments over time. Carbon offsetting is a carbon trading mechanism that enables businesses to compensate for their greenhouse gas emissions by investing in projects that reduce, avoid, or remove emissions elsewhere. One carbon credit represents a reduction, avoidance or removal of one metric ton of carbon dioxide or its carbon dioxide-equivalent. Carbon offset and credit programs provide a mechanism for countries to meet their Nationally Determined Contributions commitments to achieve the goals of the Paris Agreement.

__Project Objective__ : To create a platform that provides users the ability to earn money by being eco-friendly.  
__Key Deliverables__: To produce a mobile application where users are able to collect crypto-tokens and exchange them for money from companies, using blockchain technology.  
__Software Details__: Flutter(Front-end), Ethereum (Back-end)  
__Required Software__: Ganache (Private Ethereum Blockchain), Remix (Compile & Deploy Smart Contract), IDE (To build and run Flutter code)  

For the purposes of this project, we will be using Ganache. Ganache will create a simple private Ethereum blockchain along with 10 accounts initialized with 100 Eth. However for real world use cases, the Ethereum mainnet will be used instead, and the accounts used will be the personal accounts of users which they generate on their personal wallet software. In this way, users will be able to access the Eth they obtain from exchanging tokens.

![Usecase_and_Subsystems](https://github.com/kangzhaowong/Carbon_Credits_Token_Dapp/assets/117423228/8e00ddca-1d30-4698-8c80-134f2ead81cc)

## User Assumptions
1. In order to perform write functions to the Ethereum blockchain, the user needs to have an Ethereum account as write functions incur transaction fees. Therefore for this Dapp, we have to assume the user has an existing Ethereum account with enough balance to cover transaction fees is needed.
2. When exchanging a small amount of tokens, there might be a situation where the transaction fees is higher than the Eth earned, resulting in the user losing Eth instead. For this Dapp, we have to assume the user understands how transaction fees work and exchange tokens in amounts that result in earnings larger than the transaction fees.

## Setup Blockchain
1. Create a new private Ethereum blockchain using Ganache and save it
2. On Remix, change envrionment to Dev - Ganache. Ganache JSON-RPC Endpoint is the RPC SERVER (usually HTTP://127.0.0.1:7545)
3. Compile LeafContract.sol on Remix using Solidity compiler 0.8.19
4. Deploy LeafContract.sol with the administator's address
5. Remember to save the deployed contract address
6. Port forward the Ganache JSON-RPC Endpoint to a public web url (I used VScode to port forward to https://XXXXXXXX-7545.asse.devtunnels.ms/ and set its visibility to public)

## Setup constants.dart
1. Under _ _./lib_ _ in both the admin Dapp and user Dapp, there is a constants.dart file which contains the url that the Dapp will connect to
2. For the user Dapp, change RPC_URL and WS_URL to the public web url which the Ganache JSON-RPC Endpoint has been port forwarded (https://XXXXXXXX-7545.asse.devtunnels.ms/), and change the contract address to deployed contract address
3. For the admin Dapp, change RPC_URL and WS_URL to the Ganache JSON-RPC Endpoint (HTTP://127.0.0.1:7545) if the Dapp is being run on the same device/computer as the Ganache private Etheruem blockchain, else change RPC_URL and WS_URL to the public web url which the Ganache JSON-RPC Endpoint has been port forwarded (https://XXXXXXXX-7545.asse.devtunnels.ms/), and change the contract address to deployed contract address, and change ALL_PRIVATE_KEYS to the private keys in the Ganache private Ethereum blockchain (Private keys can be found by pressing the key button) 

## Running the admin Dapp
1. Build the flutter app using `flutter run`
2. To add partner company, change the selection box to the administator account and type in the text field the partner company address, partner company name, and the exchange rate(integer), seperated by commas. For example, 0x50708fc313b6f309bf1c73e3808a801c45ee216d38f3f0fe225300d5241eb7dc,Orange,100
3. For user to exchange tokens with the partner company, the partner company needs to add funds to the smart contract. Change the selection box to partner company address, and enter the amount of funds to add to the text field and press enter
4. Once the partner company has enough funds (50 Eth), users will be able to see and exchange tokens with the partner company
5. For the user to obtain their tokens, will we generate a QR code for them to scan. Change the selection box to partner company address and enter the amount of tokens to be given in the text field. Press the New Leaf Code button

 ## Running the user Dapp
 1. Build the flutter app on your device (Android,Chrome) using `flutter run` (IOS has not been tested as I do not have one to test with)
 2. As the Dapp uses Blockchain, be aware that functions from the smart contract may take time to run
 3. In the profile tab, connect to your account using your private key obtained from one of the accounts generated by Ganache using the Connect Account button
 4. In the home tab, pressing the scan QR code button will allow the user to scan for the QR code that allows them to collect their tokens
 5. In the exchange tab, pressing the exchange icon of the partner company will allow the user to enter the amount of tokens they want to exchange and exchange for Ethereums
 6. There is a help button on the home screen which explains how to use the Dapp
