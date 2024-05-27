// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{

    NetworkConfig public activeNetworkConfig;

    struct NetworkConfig{
        address priceFeed;
    }

    uint8 public constant DECIMALS = 8;
    int256 public constant INTIAL_ANSWER = 2000e8;
    constructor(){
        if(block.chainid == 11155111) activeNetworkConfig = getSepoliaConfig();
        else if(block.chainid == 1) activeNetworkConfig = getEthMainNetConfig();
        else activeNetworkConfig = getOrCreateAnvilEthConfig();
    }

    function getSepoliaConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed : 0x694AA1769357215DE4FAC081bf1f309aDC325306 
        });
        return sepoliaConfig;
    }
    function getEthMainNetConfig() public pure returns(NetworkConfig memory){
        NetworkConfig memory mainNetConfig = NetworkConfig({
            priceFeed : 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419 
        });
        return mainNetConfig;
    }

    function getOrCreateAnvilEthConfig() public returns(NetworkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }
        // 1. Deploy the mock
        // 2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INTIAL_ANSWER);
        vm.stopBroadcast();
        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed:address(mockPriceFeed)
        });
        return anvilConfig;
    }
}