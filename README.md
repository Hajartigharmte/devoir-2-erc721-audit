# Devoir 2 — Certification Académique ERC-721 & Audit de Sécurité

Projet réalisé dans le cadre du **Devoir 2**, étendant le registre de certificats vers le standard **ERC-721** (`ERC721URIStorage`) avec contrôle d'accès (`AccessControl`), protection contre la réentrance (`ReentrancyGuard`), tests de sécurité et rapport d'audit simplifié.

## Structure du projet
- `contracts/CertificateRegistryERC721.sol` : contrat principal ERC-721 (émission unitaire, émission par lot, révocation, consultation, unicité et rôles).
- `scripts/deploy.js` : script de déploiement (syntaxe ESM).
- `test/CertificateRegistryERC721.test.js` : tests unitaires et de sécurité Hardhat.
- `frontend/index.html` : interface web d'interaction avec le contrat.
- `AUDIT_REPORT.md` : rapport d'audit simplifié.

## Commandes utiles

### 1. Compilation et tests unitaires
npx hardhat compile
npx hardhat test

### 2. Déploiement en local
Dans un premier terminal :
npx hardhat node

Dans un second terminal :
npx hardhat run scripts/deploy.js --network localhost

### 3. Lancer l'interface web
Ouvrir `frontend/index.html` via un serveur local (ex. Live Server sur `127.0.0.1:5500/frontend/index.html`)[cite: 4], vérifier l'adresse du contrat déployé, puis connecter MetaMask sur le réseau local (`127.0.0.1:8545`).

## Sécurité et audit
Voir le fichier **`AUDIT_REPORT.md`** pour le périmètre audité, la checklist (`OK` / `À compléter`), les vérifications de sécurité, les résultats des tests et les pistes d'amélioration.