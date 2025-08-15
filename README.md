# Nusapay-Core

***


# OVERVIEW

***

# Intro to NusaPay

## What is NusaPay

NusaPay is a permissionless cross-border payment protocol built on Etherlink. It is designed to provide a fast, affordable, and seamless decentralized experience for international payroll and remittances across multiple blockchain environments.

Key components include:

* [**Etherlink**](https://www.etherlink.com/), a fast and cost-efficient Layer 2 solution for our core operations.
* [**Hyperlane**](https://app.gitbook.com/o/aUZYAMWOkaDjYCNxvVS6/s/k7kvMqvlkCQWT9DUslOu/), used for trustless cross-chain messaging and secure asset movement.

***

## Key Features

* **Near-Zero Fees:** NusaPay leverages the low-cost environment of [**Etherlink**](https://www.etherlink.com/). Our mass payroll transactions are confirmed quickly and cost just a fraction of typical gas fees, making global payments highly economical.
* **Permissionless:** Built on Web3 principles, NusaPay allows anyone to use its services without requiring administrative keys or centralized controls, ensuring full transparency and user sovereignty.
* **Fast Cross-Chain Interoperability:** NusaPay enables seamless cross-chain interactions using [**Hyperlane**](https://app.gitbook.com/o/aUZYAMWOkaDjYCNxvVS6/s/k7kvMqvlkCQWT9DUslOu/) for secure, decentralized communication between blockchains, allowing us to move funds from any supported chain to [**Etherlink**](https://www.etherlink.com/) for processing.
* **Direct-to-Bank Payouts:** We bridge the on-chain and off-chain worlds by converting digital assets into local fiat currencies and depositing them directly into the recipient's bank account.

***

## Why Built on Etherlink?

NusaPay is built on Etherlink, an EVM-compatible, non-custodial Layer 2 blockchain powered by Tezos Smart Rollup technology. Etherlink was chosen for its exceptional performance, developer experience, and strong security guarantees, all of which are essential for a reliable cross-border payment platform.

***

### What is Etherlink?

Etherlink enables seamless integration with Ethereum tools such as wallets and indexers, and allows fast asset transfers to and from other EVM-compatible chains.

Built on the Tezos Layer 1, Etherlink offers a fast, fair, and (nearly) free environment for DeFi protocols and applications.

* **Fast Confirmation:** Etherlink provides low-latency confirmations under 500 milliseconds, allowing for real-time user experiences. By leveraging Tezos's 2-block finality and the speed of Smart Rollups, Etherlink ensures both fast and secure transaction execution. For NusaPay, this is critical for rapid processing of mass payments.
* **Fair and Open Governance:** Etherlink governance integrates with Tezos’s permissionless fraud-proof mechanisms. Participation is open to anyone, ensuring transparency and fairness without administrative keys or centralized controls. Users retain full control of their assets, reducing the risk of censorship or manipulation.
* **Low Transaction Costs:** Etherlink drastically reduces transaction costs by using enshrined Smart Rollups. This architecture supports scalable application development without cost barriers, making it the perfect foundation for NusaPay's high-volume mass payroll transactions.

***

# Problem

**Cross-border payments**, especially for enterprise-scale needs like international payroll, are currently facing profound challenges that hinder the efficiency of the global digital economy. These issues are rooted in rigid and fragmented conventional financial systems.

**Key Limitations of Current Systems:**

### **Expensive and Slow**

Traditional payment processes, such as SWIFT transfers, involve numerous intermediaries (correspondent banks) that impose high fees and cause delays lasting several business days. Consequently, companies bear significant operational burdens, while employees have to wait an unacceptably long time to receive their salaries.

***

### **Lacking Transparency**

The lack of visibility over fund flows makes it difficult for companies to track payment statuses in real-time. On the receiving end, hidden fees and unfavorable exchange rates can erode the value of a salary, leading to uncertainty and dissatisfaction.

***

### **Inefficient for Mass Payments**

Existing systems are not designed for automated mass payments. Companies must manage individual transfers to various countries, a process that is complex, error-prone, and highly resource-intensive.

***

### **Centralized and Outdated**

Conventional solutions rely on centralized institutions that are susceptible to single points of failure and a lack of digital innovation. They fail to harness the full potential of fast and efficient digital assets.

***

In summary, the current state of cross-border payments creates friction that is detrimental to both businesses and individuals, impeding the growth of an inclusive and efficient digital economy.

***

# Solution

NusaPay is the bridge needed to solve the cross-border payment problem in the digital era. We offer a platform that is completely **decentralized, automated, and efficient** for international payroll and remittances.

**How NusaPay Solves the Problem:**

### **Direct and Automated Bridge**

We create a direct and trustless bridge from digital assets (such as USDC) to local fiat currencies. The entire process, from a company sending funds to an employee receiving them in their bank account, is automated via smart contracts deployed on Etherlink.

***

### **Efficiency and Low Costs**

By leveraging Etherlink's near-zero gas fees and extremely fast transaction confirmations, NusaPay enables mass payments that are significantly more economical and rapid. We eliminate unnecessary intermediaries, ensuring employees receive their full intended salary.

***

### **Full Transparency and Interoperability**

Every transaction is recorded transparently on the blockchain. We use Hyperlane as our interoperability protocol to ensure digital assets can move securely and efficiently from other blockchains to Etherlink, guaranteeing flexibility and connectivity.

***

### **Designed for Global Scale**

NusaPay is built specifically to meet the needs of global companies, freelancer platforms, and DAOs. We provide a unified and simple solution for mass payments, freeing up HR and finance teams from heavy administrative burdens.

***

By combining the power of Web3 with traditional banking integration, NusaPay not only overcomes the limitations of existing systems but also creates a new foundation for a truly inclusive and efficient future of digital finance.

***

# Tech Stack

***

# Hyperlane

**Hyperlane** serves as our core cross-chain interoperability protocol, providing a crucial layer of connectivity for NusaPay. It is a permissionless and open-source messaging standard that enables our smart contracts on Etherlink to securely communicate with and move assets from any other supported blockchain. For NusaPay, this is vital for the mass payroll process. It ensures that an employer can initiate a payment using USDC from any chain they prefer, and Hyperlane will handle the trustless transfer of these assets to our processing environment on Etherlink. This eliminates the need for vulnerable, centralized bridges and provides the flexibility required for a truly global payment platform.

***

# RedStone

**RedStone** provides reliable and real-time oracle data, a non-negotiable component for NusaPay's automated conversion process. While most oracle solutions push data onto the blockchain at set intervals, RedStone operates on a unique "pull-based" model, where our smart contracts can fetch the latest price data on-demand. This ensures that when our system performs a swap of USDC to our local currency representation (IDRX) on a DEX, we are using the most current and accurate exchange rate. This guarantees the integrity of our transactions and protects against price manipulation, which is essential for a financial service where every cent matters.

***

# Thirdweb

**Thirdweb** is our strategic choice to accelerate the development and deployment of NusaPay's smart contracts. It offers a comprehensive suite of developer tools, including easy-to-use SDKs and a library of pre-built, production-ready smart contracts. By leveraging Thirdweb, our development team can abstract away much of the boilerplate code and focus entirely on building NusaPay's unique business logic—such as the complex payroll orchestration and our on-chain to off-chain payout mechanisms. This streamlined developer experience is particularly valuable for a fast-paced project like ours, enabling us to innovate and iterate rapidly on **Etherlink**.

***

# Goldsky

**Goldsky** functions as a real-time data streaming platform, acting as the nervous system that connects our on-chain logic to our off-chain backend services. Our Local Currency Smart Contract on Etherlink emits a specific event once a transaction is verified and ready for fiat payout. Goldsky continuously monitors the blockchain for these events, ensuring that our NusaPay Backend/API receives this signal instantly and reliably. This robust event-driven architecture is critical for the on-chain to off-chain bridge, guaranteeing that the final step of transferring fiat to the employee's bank account is triggered with speed, accuracy, and without any delay.

***

# HOW IT WORKS

***

# How We Achieve Cross-border Capability

NusaPay leverages a sophisticated, yet streamlined, architecture to deliver seamless cross-border payroll and payment capabilities. Our process ensures that digital assets are efficiently converted and delivered to local bank accounts, anywhere in the world.

Our cross-border capability is engineered through a multi-faceted approach, designed for clarity, efficiency, and global reach:

{% stepper %}
{% step %}
### **Global Digital Asset Ingestion**

The process begins with the Employer initiating payments using stable digital assets such as USDC. This provides a universal entry point, unconstrained by geographical banking limitations.
{% endstep %}

{% step %}
### **Intelligent Cross-Chain Routing**

For scenarios where the employer's digital assets reside on a different blockchain than our core processing Smart Contract on **Etherlink**, NusaPay employs robust cross-chain interoperability solutions. **Our Payroll Smart Contract** can securely route **USDC via Hyperlane** from an external blockchain to **Etherlink**. This step is handled seamlessly in the background, abstracting blockchain complexities from the employer.
{% endstep %}

{% step %}
### **Localized Digital Asset Representation & Conversion**

Once the digital asset (USDC) arrives on Etherlink, it interacts with our **Local Currency Smart Contract** (e.g., IDRX SC). This smart contract then emits a 'deposit event,' signaling the readiness for conversion and payout.
{% endstep %}

{% step %}
### **Off-Chain Integration for Fiat Payout**

Our specialized **Local Currency Backend/API** acts as the crucial bridge to the traditional financial system. This backend constantly monitors the blockchain for conversion and payout signals from the Local Currency Smart Contract. Upon receiving such signals, it triggers an immediate transfer of the corresponding fiat amount (e.g., IDR) from our local banking partners directly into the **Employee's Bank** account.
{% endstep %}

{% step %}
### **Multi-Jurisdictional Scalability**

While examples illustrate a particular flow (e.g., for Indonesian Rupiah), NusaPay's architecture is built for **global extensibility**. The "Local Currency Smart Contract" and "Local Currency Backend/API" components represent a modular design that can be replicated and integrated with local banking infrastructure in numerous other countries. This enables us to support a wide range of local currencies and banking systems, allowing employers to pay employees worldwide through a single, unified platform.
{% endstep %}
{% endstepper %}

This integrated flow ensures that employers can initiate international payroll efficiently with digital assets, while employees receive their salaries directly in their local bank accounts, bridging the gap between blockchain and traditional finance for global remuneration. Our architecture is designed to be extensible, supporting various local currency representations and banking integrations to scale our cross-border reach.

***

# The On-chain to Off-chain Bridge

This section focuses specifically on the innovative mechanism that bridges the blockchain world (on-chain) with the traditional banking system (off-chain), a crucial step for achieving our direct-to-bank payout feature.

The bridge is powered by the symbiotic relationship between our **Local Currency Smart Contract** and the **NusaPay Backend/AP**I. The Smart Contract serves as the **on-chain trigger** by emitting a specific event once a transaction is verified and ready for payout. The Backend/API, in turn, acts as the **off-chain executor**, constantly listening for these events. Upon detecting a payout signal, it securely communicates with our local banking partners to initiate the final fiat transfer. This automated, event-driven model ensures that the transition from a digital asset on a blockchain to a traditional bank deposit is executed with speed, security, and minimal human intervention.

***

# The Role of Hyperlane Interoperability

At the heart of NusaPay's cross-border flexibility lies **Hyperlane**, a core component of our technical stack. Hyperlane enables our platform to operate seamlessly across different blockchain networks, ensuring that our system is not confined to a single chain.

Hyperlane provides a secure and trustless mechanism for our **Payroll Smart Contract** on **Etherlink** to receive digital assets from any supported external blockchain. It does this by facilitating secure message passing and asset bridging without relying on centralized or multi-sig intermediaries. This architectural choice is fundamental for NusaPay as it allows employers to initiate payments from their preferred blockchain, while the core payroll processing logic remains centralized and secure on **Etherlink**.

***

# The Automated Mass Payroll Flow

This section describes the end-to-end user journey, highlighting how NusaPay simplifies the complex process of international payroll for companies.

1. Employer Experience
2. Smart Contract Orchestration:&#x20;
3. Efficiency at Scale: This automated and unified flow makes sending payroll to dozens or even hundreds of employees in different countries as simple as one action. It eliminates the manual work, high fees, and reconciliation headaches associated with traditional methods, providing companies with a scalable and cost-effective solution for their global workforce.

{% stepper %}
{% step %}
**Employer Experience**

An employer begins by logging into NusaPay's platform, where they can easily upload a list of employees and their payroll details. With a single click and a single transaction in USDC, the employer initiates a mass payment to all employees, regardless of their country of residence.
{% endstep %}

{% step %}
**Smart Contract Orchestration**

Our Payroll Smart Contract acts as the central hub for this process. It processes the mass payment data, triggers the necessary cross-chain transfers (via Hyperlane if needed), and then initiates the conversion and payout logic for each individual employee, all within a single, atomic, and verifiable process.
{% endstep %}

{% step %}
**Efficiency at Scale**

This automated and unified flow makes sending payroll to dozens or even hundreds of employees in different countries as simple as one action. It eliminates the manual work, high fees, and reconciliation headaches associated with traditional methods, providing companies with a scalable and cost-effective solution for their global workforce.
{% endstep %}
{% endstepper %}

***

# developer docs

***

# Introduction

Welcome to the NusaPay Developer Documentation. These documents are designed for builders and contributors who want to understand the core mechanics of our protocol. Here, you will find a detailed breakdown of our architecture, smart contract interfaces, off-chain integration points, and tools to get you started with building on NusaPay. Our goal is to provide a comprehensive guide for anyone looking to integrate with or extend our cross-border payment functionality on **Etherlink**.

***

# Architecture

***

# Technical Details and Development

***

# DEPLOYMENTS

***

# Chains

***

# Arbitrum Sepolia

# Chain Metadata and Addresses by Hyperlane

NusaPay utilizes Hyperlane to enable permissionless cross-chain communication. All metadata and contract addresses presented in this section are generated through Hyperlane’s deployment flow. This includes core components such as the Mailbox, Interchain Security Module (ISM), and relayer infrastructure, configured specifically for NusaPay’s supported chains, particularly Etherlink Testnet.

## Chain Metadata

```yaml
# yaml-language-server: $schema=../schema.json
blockExplorers:
  - apiKey: DG7K8I1UG76QJMKKFEQJJ8R7B7X2P81ZI7
    apiUrl: https://api-sepolia.arbiscan.io/api/
    family: etherscan
    name: arbiscan
    url: https://sepolia.arbiscan.io/
chainId: 421614
displayName: Arbitrumsepolia
domainId: 421614
index:
  from: 178250468
isTestnet: true
name: arbitrumsepolia
nativeToken:
  decimals: 18
  name: Ether
  symbol: ETH
protocol: ethereum
rpcUrls:
  - http: https://arbitrum-sepolia.drpc.org
technicalStack: arbitrumnitro
```

## Addresses

```solidity
domainRoutingIsmFactory: "0xF96850aaa60498bBbfafBA2aBa9442fcEaea6e9D"
interchainAccountRouter: "0xdf2706AD5966ac71C9016b4a4F93c9054e48F54b"
mailbox: "0xeeCe1088FD44E74Eb7B0045a4798a4c97A8143dC"
merkleTreeHook: "0x4569c7867cD0AEB5dfF299a0278A68Cf27397C7c"
proxyAdmin: "0x102C84531182DC33540A353F94a364809bC89B16"
staticAggregationHookFactory: "0x26251544bd58FeB98D575f35DBbF0E1F3599382C"
staticAggregationIsmFactory: "0xdE5F67b034D1D67dC057CCc349f7B9DA784dF08F"
staticMerkleRootMultisigIsmFactory: "0xC259945Af9604Fb42EEeaA63fc15cfC69136f640"
staticMerkleRootWeightedMultisigIsmFactory: "0x10D4aEd4B5336ca77BC970A3939bc6EE32Ddd4Af"
staticMessageIdMultisigIsmFactory: "0xcB073E4f00a07d74383b2F2214159eA56026ADff"
staticMessageIdWeightedMultisigIsmFactory: "0x471845C0Db6219932CD96F9Fe78eb6bEBd076eeb"
testRecipient: "0x797e0d9957ff4EeFa3330e809A10820ddC2937dc"
validatorAnnounce: "0xd88B4457cB127B79cf6d7f49dFaE21eca30cdC60"
```

# RPC URL and Token Addresses

## RPC URL

<table data-full-width="false"><thead><tr><th align="center">Parameter</th><th align="center" valign="middle">Value</th></tr></thead><tbody><tr><td align="center">Chain ID</td><td align="center" valign="middle">421614</td></tr><tr><td align="center">Network Name</td><td align="center" valign="middle">Arbitrum Sepolia</td></tr><tr><td align="center">RPC URL</td><td align="center" valign="middle"><a href="https://sepolia-rollup.arbitrum.io/rpc">https://sepolia-rollup.arbitrum.io/rpc</a></td></tr><tr><td align="center">Currency Symbol</td><td align="center" valign="middle">ETH</td></tr><tr><td align="center">Block Explorer (Optional)</td><td align="center" valign="middle"><a href="https://sepolia.arbiscan.io/">https://sepolia.arbiscan.io/</a></td></tr></tbody></table>

To add the chain to your wallet, you can seamlessly do so via [Chainlist](https://chainlist.org/chain/421614).

## Token Adresses

<table><thead><tr><th width="310.4140625" align="center">Token Name</th><th align="center">Address</th></tr></thead><tbody><tr><td align="center">mockUSDC</td><td align="center">0x93Abc28490836C3f50eF44ee7B300E62f4bda8ab</td></tr><tr><td align="center">mockUSDT</td><td align="center">0x8B34f890d496Ff9FCdcDb113d3d464Ee54c35623</td></tr><tr><td align="center">mockWXTZ</td><td align="center">0x64D3ee701c5d649a8a1582f19812416c132c9700</td></tr><tr><td align="center">mockWBTC</td><td align="center">0xa998cBD0798F827a5Ed40A5c461E5052c06ff7C6</td></tr><tr><td align="center">mockWETH</td><td align="center">0x9eCee5E6a7D23703Ae46bEA8c293Fa63954E8525</td></tr></tbody></table>

***

# Base Sepolia

# Chain Metadata and Addresses by Hyperlane

NusaPay utilizes Hyperlane to enable permissionless cross-chain communication. All metadata and contract addresses presented in this section are generated through Hyperlane’s deployment flow. This includes core components such as the Mailbox, Interchain Security Module (ISM), and relayer infrastructure, configured specifically for NusaPay’s supported chains, particularly Base Sepolia.

## Chain Metadata

```yaml
# yaml-language-server: $schema=../schema.json
blockExplorers:
  - apiKey: DG7K8I1UG76QJMKKFEQJJ8R7B7X2P81ZI7
    apiUrl: https://api-sepolia.basescan.org/api
    family: etherscan
    name: Base Sepolia Network Testnet Explorer
    url: https://sepolia.basescan.org/
chainId: 84532
displayName: Basesepolia
domainId: 84532
isTestnet: true
name: basesepolia
nativeToken:
  decimals: 18
  name: Ether
  symbol: ETH
protocol: ethereum
rpcUrls:
  - http: https://sepolia.base.org
technicalStack: opstack
```

## Adresses

```solidity
domainRoutingIsmFactory: "0x1633691b289376D25734e302A84382aAb05B7b83"
interchainAccountRouter: "0x677a021bdf36a7409D02A974cb6E19EE4c2F0632"
mailbox: "0x743Ff3d08e13aF951e4b60017Cf261BFc8457aE4"
merkleTreeHook: "0x73D8704B5278793900A4fa7dBF762e7FF2e82FAE"
proxyAdmin: "0x9722A6a4DFc346128C04534511aACFffA0318c17"
staticAggregationHookFactory: "0x7829DbB93c2adfa103b7eC9EB06919017aDA77Da"
staticAggregationIsmFactory: "0xA8019B951351a8b1E7a3c7A34878eD50C858dc6b"
staticMerkleRootMultisigIsmFactory: "0xC145B01CD938B55eEFF795C746F1F203f414ccb5"
staticMerkleRootWeightedMultisigIsmFactory: "0x74F303d4e879a595CD76187da5a5328106cF3eD3"
staticMessageIdMultisigIsmFactory: "0x76ca0BE1B7A0da83Fc1B27E50B32fBfDeAf5A698"
staticMessageIdWeightedMultisigIsmFactory: "0x76B4EEe7e92052BDfd60E4D44AD08562266BBa53"
testRecipient: "0x868849781fa74B201E92535CadDc1d3775d9038a"
validatorAnnounce: "0xc2BAe15C59dc7Debe059476152DecC4B64A92b8b"
```

# RPC URL and Token Addresses

## RPC URL

|         Parameter         |                                       Value                                      |
| :-----------------------: | :------------------------------------------------------------------------------: |
|          Chain ID         |                                       84532                                      |
|        Network Name       |                                   Base Sepolia                                   |
|          RPC URL          | [https://sepolia-rollup.arbitrum.io/rpc](https://sepolia-rollup.arbitrum.io/rpc) |
|      Currency Symbol      |                                        ETH                                       |
| Block Explorer (Optional) |          [https://sepolia.basescan.org/](https://sepolia.basescan.org/)          |

To add the chain to your wallet, you can seamlessly do so via [Chainlist](https://chainlist.org/chain/84532).

## Token Addresses

<table><thead><tr><th width="309.53515625" align="center">Token Name</th><th align="center">Address</th></tr></thead><tbody><tr><td align="center">mockUSDC</td><td align="center">0xdfd290562Ce8aB4A4CCBfF3FC459D504a628f8eD</td></tr><tr><td align="center">mockUSDT</td><td align="center">0xF597525130e6295CFA0C75EA968FBf89D486c528</td></tr><tr><td align="center">mockWXTZ</td><td align="center">0x10d3743F6A987082CB7B0680cA2283F5839e77CD</td></tr><tr><td align="center">mockWBTC</td><td align="center">0x11603bf689910b9312bd0915749095C12cc92ac1</td></tr><tr><td align="center">mockWETH</td><td align="center">0x9A2Da2FA519AFCcCc6B33CA48dFa07fE3a9887eF</td></tr></tbody></table>

***

# Etherlink Testnet

# Chain Metadata and Addresses by Hyperlane

NusaPay utilizes Hyperlane to enable permissionless cross-chain communication. All metadata and contract addresses presented in this section are generated through Hyperlane’s deployment flow. This includes core components such as the Mailbox, Interchain Security Module (ISM), and relayer infrastructure, configured specifically for NusaPay’s supported chains.

## Chain Metadata

```yaml
# yaml-language-server: $schema=../schema.json
chainId: 128123
displayName: Etherlinktestnet
domainId: 128123
isTestnet: true
name: etherlinktestnet
nativeToken:
  decimals: 18
  name: Tezos
  symbol: XTZ
protocol: ethereum
rpcUrls:
  - http: https://node.ghostnet.etherlink.com
technicalStack: other
```

## Addresses

```solidity
domainRoutingIsmFactory: "0x05e78872ab0AFb3b89022Bc3a729447B19E8121a"
interchainAccountRouter: "0xC4c34aFF9f5dE4D9623349ce8EAc8589cE796fD7"
mailbox: "0xDfaa17BF52afc5a12d06964555fAAFDADD53FF5e"
merkleTreeHook: "0x3A1d7877C714AF1EF07Fb9261230458B7c2DBDD6"
proxyAdmin: "0x44C310C4Fe971C6E4Ee50510D6190B80082E93CD"
staticAggregationHookFactory: "0xB0986dE848059C50974c40D0B747241cf1F11471"
staticAggregationIsmFactory: "0xf5c7624c3054C5F093EfE22BdA58eFbe120a4B43"
staticMerkleRootMultisigIsmFactory: "0x7Ac151F5A2e2B660bD9f7F4761272c15B15b0DDB"
staticMerkleRootWeightedMultisigIsmFactory: "0x66195c626CD49d15066F07cf1015D895980A6E61"
staticMessageIdMultisigIsmFactory: "0xbFc5D78E1B69F6f194C5822Ad55CFD1ae0fF796c"
staticMessageIdWeightedMultisigIsmFactory: "0xa8F162af976b55cACE08F4D7088aa69B6fcb3bF6"
testRecipient: "0x4De55A12c612612A234d63639A322Ca31ec427f8"
validatorAnnounce: "0x5767e69E6a56BADd04042F79175d6D7c4CEa6D14"
```

# RPC URL and Token Addresses

## RPC URL

|         Parameter         |                                       Value                                      |
| :-----------------------: | :------------------------------------------------------------------------------: |
|          Chain ID         |                                      128123                                      |
|        Network Name       |                                 Etherlink Testnet                                |
|          RPC URL          | [https://sepolia-rollup.arbitrum.io/rpc](https://sepolia-rollup.arbitrum.io/rpc) |
|      Currency Symbol      |                                        XTZ                                       |
| Block Explorer (Optional) | [https://testnet.explorer.etherlink.com](https://testnet.explorer.etherlink.com) |

To add the chain to your wallet, you can seamlessly do so via [Chainlist](https://chainlist.org/chain/84532).

## Token Addresses

<table><thead><tr><th width="309.53515625" align="center">Token Name</th><th align="center">Address</th></tr></thead><tbody><tr><td align="center">mockUSDC</td><td align="center">0xB8DB4FcdD486a031a3B2CA27B588C015CB99F5F0</td></tr><tr><td align="center">mockUSDT</td><td align="center">0x2761372682FE39A53A5b1576467a66b258C3fec2</td></tr><tr><td align="center">mockWXTZ</td><td align="center">0x0320aC8A299b3da6469bE3Da9ED6c84D09309418</td></tr><tr><td align="center">mockWBTC</td><td align="center">0x50df5e25AB60e150f753B9444D160a80f0279559</td></tr><tr><td align="center">mockWETH</td><td align="center">0x0355360B7F943974404277936a5C7536B51B9A77</td></tr></tbody></table>

***

# Protocol Adresses

***

# Oracles

***

# Goldsky

***

# NUSAPAY GUIDES

***

# NusaPay Testnet

***

# Testnet Faucets

***

# OTHERS

***

# Links

***


