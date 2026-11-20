# Rapport d'Audit 

## 1. Périmètre audité
- **Contrat intelligent :** `contracts/CertificateRegistryERC721.sol` (standard **ERC-721** basé sur OpenZeppelin : `ERC721URIStorage`, `AccessControl`, `ReentrancyGuard`).
- **Configuration & outillage :** Solidity `0.8.24`, cible EVM `cancun`, optimisations activées (`viaIR: true`), scripts ESM (`scripts/deploy.js`) et tests unitaires (`test/CertificateRegistryERC721.test.js`).
- **Interface utilisateur :** `frontend/index.html` (connexion portefeuille, émission unitaire et par lot, vérification et révocation par `tokenId`, gestion d'erreurs).

## 2. Checklist de sécurité

| Point de contrôle | Statut | Observation |
| :--- | :---: | :--- |
| **Contrôle d'accès par rôles** (`MINTER_ROLE` / `DEFAULT_ADMIN_ROLE`) | **OK** | L'émission (`mintCertificate`, `batchMintCertificates`) est réservée à `MINTER_ROLE` et la révocation (`revokeCertificate`) à `DEFAULT_ADMIN_ROLE` ; un compte sans rôle est rejeté. |
| **Unicité des identifiants étudiants** (`studentId`) | **OK** | La vérification par empreinte (`keccak256`) empêche l'émission de deux certificats avec le même `studentId`. |
| **Validation des paramètres d'entrée** | **OK** | Rejet des adresses nulles (`address(0)`) et des chaînes vides (`studentId`, `studentName`, `diplomaTitle`, `tokenURI`). |
| **Protection contre la réentrance** | **OK** | Utilisation du modificateur `nonReentrant` (`ReentrancyGuard` d'OpenZeppelin) sur les fonctions sensibles. |
| **Traçabilité par événements** | **OK** | Émission des événements `CertificateMinted` et `CertificateRevoked` avec `tokenId` indexé. |
| **Révocation d'un certificat** | **OK** | Passe l'état à révoqué (`revoked = true`) tout en conservant la trace on-chain ; à surveiller côté logique de vérification/transfert selon le besoin métier. |
| **Gestion des erreurs côté interface** | **OK** | Affichage clair des erreurs de rôle, doublons ou transactions annulées dans `frontend/index.html`. |
| **Vérification manuelle complète sur navigateur avec compte `MINTER_ROLE`** | **À compléter** | À finaliser dans MetaMask une fois le compte disposant de `MINTER_ROLE` connecté sur le réseau local. |

## 3. Vulnérabilités / Risques vérifiés
1. **Élévation de privilèges / appel non autorisé :** prévenue par `AccessControl` d'OpenZeppelin ; les appels depuis un compte non autorisé échouent avant modification de l'état.
2. **Doublon de certificat pour un même étudiant :** prévenu par le suivi des identifiants déjà enregistrés (`_usedStudentIdHashes`).
3. **Réentrance :** atténuée par `ReentrancyGuard` et le respect des bonnes pratiques Checks-Effects-Interactions (mise à jour de l'état avant les appels externes/événements).
4. **Débordement arithmétique :** couvert nativement par Solidity `0.8.24` (`checked arithmetic` par défaut).

## 4. Résultats des tests
- **Tests automatisés Hardhat (`npx hardhat test`) :** l'ensemble des tests unitaires et de sécurité (`CertificateRegistryERC721.test.js`) passe avec succès.
- **Vérification locale de déploiement :** déploiement vérifié sur le nœud local (`localhost`) via `scripts/deploy.js`.

## 5. Limites et améliorations futures
- **Métadonnées (`tokenURI`) :** privilégier un stockage décentralisé pérenne (ex. IPFS épinglé) et une validation du format d'URI en environnement réel.
- **Politique de transfert des diplômes :** décider explicitement si un NFT de certificat doit rester transférable ou être restreint/contrôlé lors de la vérification publique lorsqu'il est révoqué.
- **Tests end-to-end & audit approfondi :** compléter le parcours manuel complet dans le navigateur avec le compte `MINTER_ROLE` et réaliser un audit plus poussé avant tout déploiement sur un réseau public.