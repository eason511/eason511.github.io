<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Fishing Game</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; }
        button { margin: 5px; padding: 10px; }
        #leaderboard, #shop { margin-top: 20px; text-align: left; display: inline-block; }
    </style>
</head>
<body>
    <h1>Fishing Game</h1>
    <p id="status">Welcome to the fishing game!</p>
    <p>💰 Gold: <span id="gold">0</span></p>
    <button onclick="game.startFishing()">Start Fishing</button>
    <button onclick="game.upgradeRod()">Upgrade Rod (Cost: 10 Gold)</button>
    <select id="waterBodySelect" onchange="game.changeWaterBody(this.value)">
        <option value="Pond">Pond</option>
        <option value="River">River</option>
        <option value="Lake">Lake</option>
        <option value="Ocean">Ocean</option>
    </select>
    
    <h2>Leaderboard</h2>
    <div id="leaderboard"></div>
    
    <h2>Shop</h2>
    <div id="shop">
        <button onclick="game.buyBait()">Buy Bait (5 Gold)</button>
    </div>
    
    <script>
        class FishingGame {
            constructor() {
                this.fishCaught = 0;
                this.isFishing = false;
                this.rodLevel = 1;
                this.gold = parseInt(localStorage.getItem("gold")) || 0;
                this.waterBodies = ["Pond", "River", "Lake", "Ocean"];
                this.currentWaterBody = "Pond";
                this.fishTypes = [
                    { name: "Salmon", rarity: "Common", value: 5 },
                    { name: "Trout", rarity: "Common", value: 5 },
                    { name: "Tuna", rarity: "Uncommon", value: 10 },
                    { name: "Shark", rarity: "Rare", value: 20 },
                    { name: "Golden Fish", rarity: "Legendary", value: 50 }
                ];
                this.leaderboard = JSON.parse(localStorage.getItem("leaderboard")) || [];
                this.updateGold();
                this.updateLeaderboard();
            }

            upgradeRod() {
                if (this.gold >= 10) {
                    if (this.rodLevel < 5) {
                        this.rodLevel++;
                        this.gold -= 10;
                        this.updateGold();
                        this.updateStatus(`Fishing rod upgraded to level ${this.rodLevel}!`);
                    } else {
                        this.updateStatus("Your fishing rod is at max level!");
                    }
                } else {
                    this.updateStatus("Not enough gold to upgrade rod!");
                }
            }

            buyBait() {
                if (this.gold >= 5) {
                    this.gold -= 5;
                    this.updateGold();
                    this.updateStatus("You bought bait! Your chances of catching better fish increased.");
                } else {
                    this.updateStatus("Not enough gold to buy bait!");
                }
            }

            changeWaterBody(newWaterBody) {
                if (this.waterBodies.includes(newWaterBody)) {
                    this.currentWaterBody = newWaterBody;
                    this.updateStatus(`You moved to ${newWaterBody} for fishing.`);
                } else {
                    this.updateStatus("Invalid water body.");
                }
            }

            startFishing() {
                if (this.isFishing) {
                    this.updateStatus("You're already fishing!");
                    return;
                }

                this.isFishing = true;
                this.updateStatus(`Casting the fishing line in ${this.currentWaterBody}...`);

                setTimeout(() => {
                    this.catchFish();
                }, Math.random() * 3000 + 2000 - this.rodLevel * 200);
            }

            catchFish() {
                this.isFishing = false;
                const fish = this.getRandomFish();
                this.fishCaught++;
                this.gold += fish.value;
                this.updateGold();
                this.updateStatus(`You caught a ${fish.name} (${fish.rarity}) worth ${fish.value} gold in ${this.currentWaterBody}!`);
                this.updateLeaderboard(fish);
            }

            getRandomFish() {
                const probabilities = [
                    { fish: this.fishTypes[0], chance: 40 }, // Salmon
                    { fish: this.fishTypes[1], chance: 40 }, // Trout
                    { fish: this.fishTypes[2], chance: 15 }, // Tuna
                    { fish: this.fishTypes[3], chance: 4 },  // Shark
                    { fish: this.fishTypes[4], chance: 1 }   // Golden Fish
                ];

                let random = Math.random() * 100;
                let accumulatedChance = 0;

                for (const { fish, chance } of probabilities) {
                    accumulatedChance += chance;
                    if (random <= accumulatedChance) {
                        return fish;
                    }
                }
            }

            updateLeaderboard(fish = null) {
                if (fish) {
                    this.leaderboard.push({ fish: fish.name, rarity: fish.rarity });
                    localStorage.setItem("leaderboard", JSON.stringify(this.leaderboard));
                }

                let leaderboardDiv = document.getElementById("leaderboard");
                leaderboardDiv.innerHTML = "<h3>Top Catches</h3>";
                if (this.leaderboard.length === 0) {
                    leaderboardDiv.innerHTML += "No catches yet!";
                    return;
                }

                this.leaderboard.sort((a, b) => {
                    const rarityOrder = { "Common": 1, "Uncommon": 2, "Rare": 3, "Legendary": 4 };
                    return rarityOrder[b.rarity] - rarityOrder[a.rarity];
                });

                this.leaderboard.slice(0, 5).forEach((entry, index) => {
                    leaderboardDiv.innerHTML += `<p>${index + 1}. ${entry.fish} (${entry.rarity})</p>`;
                });
            }

            updateGold() {
                document.getElementById("gold").innerText = this.gold;
                localStorage.setItem("gold", this.gold);
            }

            updateStatus(message) {
                document.getElementById("status").innerText = message;
            }
        }

        const game = new FishingGame();
    </script>
</body>
</html>
