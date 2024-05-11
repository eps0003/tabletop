Random random(Time());

class Game
{
	private CPlayer@[] players;
	private dictionary hands;

	private u16[] drawPile = { 1, 2, 3, 4, 5 };
	private u16[] discardPile;

	private uint turnIndex = 0;
	private s8 turnDirection = 1;

	Game(CPlayer@[] players)
	{
		if (players.empty())
		{
			error("Game was instantiated with no players");
			printTrace();
			return;
		}

		this.players = players;

		ShuffleDrawPile(random);

		for (uint i = 0; i < players.size(); i++)
		{
			u16[] cards; // TODO: Deal cards
			hands.set(players[i].getUsername(), cards);
		}
	}

	CPlayer@[] getPlayers()
	{
		return players;
	}

	CPlayer@ getTurnPlayer()
	{
		return players.empty() ? null : players[turnIndex];
	}

	u16[] getHand(CPlayer@ player)
	{
		u16[] hand;
		hands.get(player.getUsername(), hand);
		return hand;
	}

	u16[] getDrawPile()
	{
		return drawPile;
	}

	u16[] getDiscardPile()
	{
		return discardPile;
	}

	void RemovePlayer(CPlayer@ player)
	{
		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ otherPlayer = players[i];
			if (player is otherPlayer)
			{
				discardHand(player);

				players.removeAt(i);
				hands.delete(player.getUsername());

				break;
			}
		}
	}

	void NextTurn()
	{
		turnIndex = (int(turnIndex) + turnDirection) % players.size();
	}

	void ReverseDirection()
	{
		turnDirection *= -1;
	}

	bool isPlayersTurn(CPlayer@ player)
	{
		CPlayer@ turnPlayer = getTurnPlayer();
		return turnPlayer !is null && turnPlayer is player;
	}

	bool drawCard(CPlayer@ player)
	{
		if (drawPile.empty())
		{
			return false;
		}

		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		uint index = drawPile.size() - 1;
		u16 card = drawPile[index];

		drawPile.removeAt(index);
		hand.push_back(card);

		return true;
	}

	bool playCard(CPlayer@ player, u16 card)
	{
		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		for (int i = hand.size() - 1; i >= 0; i--)
		{
			if (hand[i] == card)
			{
				hand.removeAt(i);
				discardPile.push_back(card);

				return true;
			}
		}

		return false;
	}

	bool tradeHands(CPlayer@ player1, CPlayer@ player2)
	{
		u16[] player1Hand;
		hands.get(player1.getUsername(), @player1Hand);

		u16[] player2Hand;
		hands.get(player2.getUsername(), @player2Hand);

		if (player1Hand is null || player2Hand is null)
		{
			return false;
		}

		if (player1Hand.empty() || player2Hand.empty())
		{
			return false;
		}

		hands.set(player1.getUsername(), player2Hand);
		hands.set(player2.getUsername(), player1Hand);

		return true;
	}

	bool discardHand(CPlayer@ player)
	{
		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		for (int i = hand.size() - 1; i >= 0; i--)
		{
			// Discard to the bottom of the discard pile
			discardPile.insertAt(0, hand[i]);
		}

		hand.clear();

		return true;
	}

	void ShuffleDrawPile(Random@ random)
	{
		// Durstenfeld shuffle
		// https://stackoverflow.com/a/12646864
		for (uint i = drawPile.size() - 1; i > 0; i--)
		{
			uint j = random.NextRanged(i + 1);

			u16 temp = drawPile[i];
			drawPile[i] = drawPile[j];
			drawPile[j] = temp;
		}
	}

	bool replenishDrawPile()
	{
		uint discardCount = discardPile.size();

		if (discardCount < 2)
		{
			return false;
		}

		for (uint i = 0; i < discardCount - 1; i++)
		{
			drawPile.push_back(discardPile[i]);
		}

		u16 topDiscardCard = discardPile[discardCount - 1];
		discardPile.clear();
		discardPile.push_back(topDiscardCard);

		ShuffleDrawPile(random);

		return true;
	}
}

namespace GameManager
{
	void Set(Game@ game)
	{
		getRules().set("game", @game);
	}

	Game@ get()
	{
		Game@ game;
		getRules().get("game", @game);
		return game;
	}
}
