// SPDX-License-Identifier: UNLICENSED
import {TicketToSpace2} from "src/sweepstakes_mumbai.sol";
import {MumbaiMooney} from "src/mooney_mumbai.sol";
import "lib/forge-std/src/Test.sol";
import "lib/forge-std/src/Vm.sol";

pragma solidity ^0.8.19;   

contract SweepstakestTest is Test {
    TicketToSpace2 tts;
    MumbaiMooney mm;

    bytes32 merkleRoot = 0x5070262704e6fdfb6e41f7ae4d6204831d23ca2695202ad9357d8cb1ee5d5fd4;

    bytes32[] proofA = [bytes32(0xfa631cefbad5319e818c7b91fb9d437f3bbc1ef298de2fcf5e41b2a57381e387),0xccbcfed7573ec10a8566dc69f988d518a23a2718201f1e46e2a63121e0493b21];
    bytes32[] proofB = [bytes32(0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229),0x050bafc3fbff3f13ae92e34d22935ed341803bcf7a4b840ce8ba265bf765bf79, 0xf925c75efd3b2ff0340bf238928671fc14a430c1d4abeffbf35098ae83168783];
    bytes32[] proofC = [bytes32(0x050bafc3fbff3f13ae92e34d22935ed341803bcf7a4b840ce8ba265bf765bf79),0xccbcfed7573ec10a8566dc69f988d518a23a2718201f1e46e2a63121e0493b21];
    bytes32[] proofD = [bytes32(0x6942332f07faff0fa8c16b5a8fcd0bd54e0a9bdb8d49095e7da518545c3f258f),0xccbcfed7573ec10a8566dc69f988d518a23a2718201f1e46e2a63121e0493b21];
    bytes32[] proofE = [bytes32(0xfa631cefbad5319e818c7b91fb9d437f3bbc1ef298de2fcf5e41b2a57381e387),0x5931b4ed56ace4c46b68524cb5bcbf4195f1bbaacbe5228fbd090546c88dd229];

    function setUp() public {
        tts = new TicketToSpace2();
        mm = new MumbaiMooney("MOONEY TOKEN", "MOONEY");
        tts.setMooneyToken(mm);
    }

    function testSetup() public {
        assert(tts.allowMinting() == false);
        assert(tts.getSupply() == 0);
        assert(tts.winnersCount() == 5);

        tts.setAllowMinting(true);
        tts.addMerkleRoot(merkleRoot);

        assert(tts.allowMinting() == true);
        assert(tts.getSupply() == 0);
        assert(tts.winnersCount() == 5);
        assert(tts.previousEntrantsMerkleRoot() == merkleRoot);
    }

    function testOwnerFunctions() public {
        vm.expectRevert();
        vm.startPrank(address(0));
        tts.addMerkleRoot(merkleRoot);
        
        vm.expectRevert();
        tts.setAllowMinting(true);

        vm.expectRevert();
        tts.setAllowTransfers(true);
    }

    function testClaimAndMint() public {
        address A = address(0x26EEeaC173A64C078286f0C3E8a93E913Ea4CaCA); // in whitelist
        address B = address(0x0d0cAaDa4d77B9f057988D06Bf747677cEb9f25F); // in whitelist
        address C = address(0x0724d0eb7b6d32AEDE6F9e492a5B1436b537262b); // not in whitelist. has mooney
        address D = address(0x5BFe848Ce931A74185A40241c127a45f04862632); // in whitelist, 0 MOONEY
        address E = address(0x7d82926BD22E0573Bb1Ff359f0B8448A8D5C2C1b); // not in whitelist, 0 MOONEY

        uint256 balanceA = 1000000 * 10 ** 18;
        uint256 balanceB = 1000000 * 10 ** 18;
        uint256 balanceC = 200 * 10 ** 18;

        mm.print(A, balanceA);
        mm.print(B, balanceB);
        mm.print(C, balanceC);

        // Setup
        assert(tts.allowMinting() == false);
        assert(tts.getSupply() == 0);
        assert(tts.winnersCount() == 5);

        tts.setAllowMinting(true);
        tts.addMerkleRoot(merkleRoot);

        assert(tts.allowMinting() == true);
        assert(tts.getSupply() == 0);
        assert(tts.winnersCount() == 5);
        assert(tts.previousEntrantsMerkleRoot() == merkleRoot);

        // Test whitelist
        assert(tts.canClaimFree(proofA, A));
        assert(tts.canClaimFree(proofB, B));
        assert(!tts.canClaimFree(proofC, C));
        assert(tts.canClaimFree(proofD, D));
        assert(!tts.canClaimFree(proofC, E));

        // Test Claimimg / Minting
        vm.startPrank(A);
        mm.approve(address(tts), 10000 * 10 ** 18);
        tts.mint(3); // A mints 3
        assert(tts.balanceOf(A) == 3);
        assert(tts.getSupply() == 3);
        
        tts.claimFree(proofA); // A claims for free
        assert(tts.balanceOf(A) == 4);
        assert(tts.getSupply() == 4);

        assert(!tts.canClaimFree(proofA, A));
        assert(tts.balanceOf(A) == 4);
        assert(tts.getSupply() == 4);

        vm.expectRevert();
        tts.claimFree(proofA); // A tries to claim for free again, fails (already claimed for free)
        assert(tts.balanceOf(A) == 4);
        assert(tts.getSupply() == 4);

        tts.mint(10); // A mints 10 more
        assert(tts.balanceOf(A) == 14);
        assert(tts.getSupply() == 14);

        vm.expectRevert();
        tts.mint(50); // A mints 50 more, fails (minting 50 more would put them over 50 NFTs)
        assert(tts.balanceOf(A) == 14);
        assert(tts.getSupply() == 14);
        
        vm.stopPrank();

        vm.startPrank(B);
        mm.approve(address(tts), 10000 * 10 ** 18);
        tts.mint(50); // B mints 50
        assert(tts.balanceOf(A) == 14);
        assert(tts.balanceOf(B) == 50);
        assert(tts.getSupply() == 64);

        vm.expectRevert();
        tts.claimFree(proofB); // B tires to claim for free, fails (already has maximum number of NFTS)
        assert(tts.balanceOf(A) == 14);
        assert(tts.balanceOf(B) == 50);
        assert(tts.getSupply() == 64);

        vm.stopPrank();

        vm.startPrank(C);

        assert(!tts.canClaimFree(proofC, C));
        assert(tts.balanceOf(C) == 0);
        assert(tts.getSupply() == 64);

        vm.expectRevert();
        tts.claimFree(proofC); // C tries to claim for free, fails (not in whitelist)
        assert(tts.balanceOf(C) == 0);
        assert(tts.getSupply() == 64);

        mm.approve(address(tts), 10000 * 10 ** 18);
        tts.mint(1); // C mints an NFT
        assert(tts.balanceOf(C) == 1);
        assert(tts.getSupply() == 65);

        vm.expectRevert();
        tts.mint(2); // C tries to mint 2 more, fails (not enough mooney)
        assert(tts.balanceOf(C) == 1);
        assert(tts.getSupply() == 65);

        vm.stopPrank();

        vm.startPrank(D);

        tts.claimFree(proofD); // D claims an NFT
        assert(tts.balanceOf(D) == 1);
        assert(tts.getSupply() == 66);

        vm.expectRevert();
        tts.mint(1); // D tries to mint an NFT (doesn't have any MOONEY)
        assert(tts.balanceOf(D) == 1);
        assert(tts.getSupply() == 66);

        vm.stopPrank();

        vm.startPrank(E);

        vm.expectRevert();
        tts.claimFree(proofE);  // D tries to claim an NFT (not on whitelist)
        assert(tts.balanceOf(E) == 0);
        assert(tts.getSupply() == 66);

        vm.expectRevert();
        tts.mint(1);  // E tries to mint an NFT (doesn't have any MOONEY)
        assert(tts.balanceOf(E) == 0);
        assert(tts.getSupply() == 66);

        vm.stopPrank();

        // Verfiy MOONEY balance are correct
        assert(mm.balanceOf(A) == balanceA - 13 * 100 * 10 ** 18);
        assert(mm.balanceOf(B) == balanceB - 50 * 100 * 10 ** 18);
        assert(mm.balanceOf(C) == balanceC - 1 * 100 * 10 ** 18);

        assert(mm.balanceOf(address(0x000000000000000000000000000000000000dEaD)) == 100 * 64 * 10 ** 18); // total mooney burned should be 6,400 (64 total mints)
    }
}
