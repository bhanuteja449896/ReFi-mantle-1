const ethers = require("ethers")
const mantleSDK = require("@mantleio/sdk");

async function estimateGas() {
    const l2RpcProvider = new ethers.providers.JsonRpcProvider("https://rpc.sepolia.mantle.xyz")    

    try{

    const feeData = await l2RpcProvider.getFeeData();
    console.log(`maxFeePerGas: ${feeData.maxFeePerGas}`);
    console.log(`maxPriorityFeePerGas: ${feeData.maxPriorityFeePerGas}`);

    const tx = {
        from: '0xa6688d0dcad346ecc275cda98c91086fec3fe31c',
        maxFeePerGas: feeData.maxFeePerGas,
        maxPriorityFeePerGas: feeData.maxPriorityFeePerGas,
        to: '0x96307f45900Bc6f396a512Dc89F8600D75f6f58C', 
        data: '0xde5f72fd'
    };
    
    const estimatedGas = await l2RpcProvider.estimateGas(tx);
    console.log(`Estimated gas: ${estimatedGas.toString()}`);
    console.log(`Estimated totalCost for transaction: ${estimatedGas*feeData.maxFeePerGas/1e18.toString()}`);

    } catch (error) {
        console.error('Error estimating gas:', error);
    }

}

estimateGas();