// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InvestorReputation {
    struct Investor {
        uint256 totalInvested;
        uint256 successfulCampaigns;
        uint256 reputationScore;
        uint8 tierLevel;
        uint256 lastUpdated;
    }

    mapping(address => Investor) public investorProfiles;
    
    uint256 public constant MAX_REPUTATION_SCORE = 10000;
    uint256 public constant REPUTATION_DECAY_PERIOD = 365 days;
    uint256 public constant DECAY_RATE = 10; // 10% annual decay

    event ReputationUpdated(
        address indexed investor, 
        uint256 newReputationScore, 
        uint8 newTierLevel
    );

    function updateInvestorReputation(
        address _investor, 
        uint256 _investmentAmount, 
        bool _campaignSuccessful
    ) external {
        Investor storage investor = investorProfiles[_investor];
        
        // Apply reputation decay if applicable
        if (block.timestamp > investor.lastUpdated + REPUTATION_DECAY_PERIOD) {
            investor.reputationScore = applyReputationDecay(investor.reputationScore);
        }

        // Update investment metrics
        investor.totalInvested += _investmentAmount;
        
        if (_campaignSuccessful) {
            investor.successfulCampaigns++;
        }

        // Recalculate reputation score
        investor.reputationScore = calculateReputationScore(investor);
        investor.tierLevel = calculateTierLevel(investor.reputationScore);
        investor.lastUpdated = block.timestamp;

        emit ReputationUpdated(_investor, investor.reputationScore, investor.tierLevel);
    }

    function calculateReputationScore(
        Investor memory _investor
    ) private pure returns (uint256) {
        // More sophisticated scoring mechanism
        uint256 investmentFactor = _investor.totalInvested / 1 ether;
        uint256 successFactor = (_investor.successfulCampaigns + 1) * 50;
        
        uint256 score = (investmentFactor * successFactor);
        return score > MAX_REPUTATION_SCORE ? MAX_REPUTATION_SCORE : score;
    }

    function calculateTierLevel(
        uint256 _reputationScore
    ) private pure returns (uint8) {
        if (_reputationScore < 100) return 1;
        if (_reputationScore < 500) return 2;
        if (_reputationScore < 1000) return 3;
        if (_reputationScore < 5000) return 4;
        return 5;
    }

    function applyReputationDecay(
        uint256 _currentScore
    ) private pure returns (uint256) {
        // Apply 10% annual decay to prevent stale reputation
        uint256 decayAmount = (_currentScore * DECAY_RATE) / 100;
        return _currentScore > decayAmount ? _currentScore - decayAmount : 0;
    }

    function getInvestorProfile(
        address _investor
    ) external view returns (Investor memory) {
        return investorProfiles[_investor];
    }
}