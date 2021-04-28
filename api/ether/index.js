const { ethers } = require("ethers");

const provider = new ethers.providers.JsonRpcProvider();
const signer = provider.getSigner();
const abi = [];
const contract = new ethers.Contract("addres", abi, provider);

// contract.on("battleRequest", (requested, requester, crypture, amount) => {
//   conosle.log({ requested, requester, crypture, amount });
// });

// contract.on("battleResult", (winner, loser, battleId, amount) => {
//   conosle.log({ winner, loser, battleId, amount });
// });

exports.contractWithSigner = contract.connect(signer);
