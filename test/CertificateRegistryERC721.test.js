import { expect } from "chai";
import hre from "hardhat";

const { ethers } = hre;

describe("CertificateRegistryERC721 - Standards & Sécurité", function () {
  let registry;
  let admin, student1, student2, attacker;

  beforeEach(async function () {
    [admin, , student1, student2, attacker] = await ethers.getSigners();
    const Registry = await ethers.getContractFactory("CertificateRegistryERC721");
    registry = await Registry.deploy(admin.address);
    await registry.waitForDeployment();
  });

  it("1. Doit permettre un mint réussi par l'admin/minter et stocker le tokenURI", async function () {
    const uri = "ipfs://QmExampleHash1/metadata.json";
    await expect(
      registry.mintCertificate(
        student1.address,
        "STD-2026-001",
        "Hajar Tighramte",
        "Master IDIA",
        uri
      )
    )
      .to.emit(registry, "CertificateMinted")
      .withArgs(1, student1.address, "STD-2026-001", uri);

    expect(await registry.ownerOf(1)).to.equal(student1.address);
    expect(await registry.tokenURI(1)).to.equal(uri);

    const cert = await registry.getCertificate(1);
    expect(cert.studentId).to.equal("STD-2026-001");
    expect(cert.studentName).to.equal("Hajar Tighramte");
    expect(cert.revoked).to.equal(false);
  });

  it("2. Doit refuser l'accès au mint si le compte n'a pas le MINTER_ROLE", async function () {
    await expect(
      registry
        .connect(attacker)
        .mintCertificate(
          student1.address,
          "STD-2026-002",
          "Attacker Test",
          "Fake Diploma",
          "ipfs://fake"
        )
    ).to.be.revertedWithCustomError(registry, "AccessControlUnauthorizedAccount");
  });

  it("3. Doit bloquer le double mint pour le même studentId", async function () {
    await registry.mintCertificate(
      student1.address,
      "STD-2026-001",
      "Hajar Tighramte",
      "Master IDIA",
      "ipfs://uri1"
    );

    await expect(
      registry.mintCertificate(
        student2.address,
        "STD-2026-001",
        "Autre Etudiant",
        "Master IDIA",
        "ipfs://uri2"
      )
    ).to.be.revertedWith("Student ID already minted");
  });

  it("4. Doit permettre le batchMintCertificates et émettre les événements", async function () {
    const recipients = [student1.address, student2.address];
    const ids = ["STD-01", "STD-02"];
    const names = ["Alice", "Bob"];
    const titles = ["Licence IDAI", "Master IDIA"];
    const uris = ["ipfs://uri1", "ipfs://uri2"];

    await registry.batchMintCertificates(recipients, ids, names, titles, uris);

    expect(await registry.ownerOf(1)).to.equal(student1.address);
    expect(await registry.ownerOf(2)).to.equal(student2.address);
    expect(await registry.tokenURI(2)).to.equal("ipfs://uri2");
  });

  it("5. Doit permettre la révocation par l'admin et refuser aux non-admins", async function () {
    await registry.mintCertificate(
      student1.address,
      "STD-2026-005",
      "Test Revoke",
      "Master IDIA",
      "ipfs://uri5"
    );

    await expect(
      registry.connect(attacker).revokeCertificate(1)
    ).to.be.revertedWithCustomError(registry, "AccessControlUnauthorizedAccount");

    await expect(registry.revokeCertificate(1))
      .to.emit(registry, "CertificateRevoked")
      .withArgs(1, admin.address);

    const cert = await registry.getCertificate(1);
    expect(cert.revoked).to.equal(true);
  });

  it("6. Doit rejeter les inputs invalides (adresse nulle ou champs vides)", async function () {
    await expect(
      registry.mintCertificate(
        ethers.ZeroAddress,
        "STD-06",
        "Nom",
        "Diplome",
        "ipfs://uri"
      )
    ).to.be.revertedWith("Recipient cannot be zero address");

    await expect(
      registry.mintCertificate(
        student1.address,
        "",
        "Nom",
        "Diplome",
        "ipfs://uri"
      )
    ).to.be.revertedWith("Student ID cannot be empty");
  });
});