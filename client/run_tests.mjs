import ethers from "ethers";

export function main() {
  let ABI = ["function submitZKPResponse()"];
  let iface = new ethers.utils.Interface([{
    "inputs": [
      {
        "internalType": "uint64",
        "name": "requestId",
        "type": "uint64"
      },
      {
        "internalType": "uint256[]",
        "name": "inputs",
        "type": "uint256[]"
      },
      {
        "internalType": "uint256[2]",
        "name": "a",
        "type": "uint256[2]"
      },
      {
        "internalType": "uint256[2][2]",
        "name": "b",
        "type": "uint256[2][2]"
      },
      {
        "internalType": "uint256[2]",
        "name": "c",
        "type": "uint256[2]"
      }
    ],
    "name": "submitZKPResponse",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  }]);

  let data = iface.encodeFunctionData("submitZKPResponse", [1, [0], [1,2],[[],[]], []]);

  console.log(data);
}

main();