#include "Utilities.as"

class Game
{
	private CPlayer@[] players;
	private dictionary hands;

	private u16[] drawPile = { 1, 2, 3, 4, 5 };
	private u16[] discardPile;

	private u16 turnIndex = 0;
	private s8 turnDirection = 1;

	Game(CPlayer@[] players)
	{
		this.players = players;

		print("Initialised game: " + players.size() + plural(" player", " players", players.size()));

		if (players.empty())
		{
			warn("Game was instantiated with no players");
		}

		ShuffleDrawPile();

		CBitStream bs;
		bs.write_u16(players.size());

		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ player = players[i];

			u16[] cards; // TODO: Deal cards
			hands.set(player.getUsername(), cards);

			bs.write_u16(player.getNetworkID());
		}

		if (isServer())
		{
			getRules().SendCommand(getRules().getCommandID("init game"), bs, true);
		}
	}

	Game(CBitStream@ bs)
	{
		u16 playerCount;
		if (!bs.saferead_u16(playerCount)) return;

		for (uint i = 0; i < playerCount; i++)
		{
			CPlayer@ player;
			if (!saferead_player(bs, @player)) return;

			players.push_back(player);

			u16[] hand;
			if (!deserialiseCards(bs, hand)) return;

			hands.set(player.getUsername(), hand);
		}

		if (!deserialiseCards(bs, drawPile)) return;
		if (!deserialiseCards(bs, discardPile)) return;

		if (!bs.saferead_u16(turnIndex)) return;
		if (!bs.saferead_u16(turnDirection)) return;

		print("Synced game: " + getLocalPlayer().getUsername());
	}

	void Sync(CPlayer@ player)
	{
		if (!isServer() || player.isMyPlayer()) return;

		CBitStream bs;

		bs.write_u16(players.size());

		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ gamePlayer = players[i];

			bs.write_u16(gamePlayer.getNetworkID());
			SerialiseCards(bs, getHand(gamePlayer));
		}

		SerialiseCards(bs, drawPile);
		SerialiseCards(bs, discardPile);

		bs.write_u16(turnIndex);
		bs.write_s8(turnDirection);

		getRules().SendCommand(getRules().getCommandID("sync game"), bs, player);

		print("Synced game: " + player.getUsername());
	}

	private void SerialiseCards(CBitStream@ bs, u16[] cards)
	{
		u16 cardCount = cards.size();
		bs.write_u16(cardCount);

		for (uint i = 0; i < cardCount; i++)
		{
			bs.write_u16(cards[i]);
		}
	}

	private bool deserialiseCards(CBitStream@ bs, u16[] &out cards)
	{
		u16 cardCount;
		if (!bs.saferead_u16(cardCount)) return false;

		for (uint i = 0; i < cardCount; i++)
		{
			u16 card;
			if (!bs.saferead_u16(card)) return false;

			cards.push_back(card);
		}

		return true;
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

				print("Removed player: " + player.getUsername());

				if (isServer())
				{
					CBitStream bs;
					bs.write_u16(player.getNetworkID());
					getRules().SendCommand(getRules().getCommandID("remove player"), bs, true);
				}

				break;
			}
		}
	}

	void NextTurn()
	{
		turnIndex = (int(turnIndex) + turnDirection) % players.size();

		print("Next turn: " + getTurnPlayer().getUsername());

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("next turn"), bs, true);
		}
	}

	void ReverseDirection()
	{
		turnDirection *= -1;

		print("Reversed direction: " + turnDirection);

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("reverse direction"), bs, true);
		}
	}

	bool isPlayersTurn(CPlayer@ player)
	{
		CPlayer@ turnPlayer = getTurnPlayer();
		return turnPlayer !is null && turnPlayer is player;
	}

	bool drawCards(CPlayer@ player, u16 count)
	{
		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		if (drawPile.size() < count)
		{
			if (!replenishDrawPile())
			{
				return false;
			}

			if (drawPile.size() < count)
			{
				return false;
			}
		}

		uint index = drawPile.size() - 1;
		u16 card = drawPile[index];

		drawPile.removeAt(index);
		hand.push_back(card);

		print("Drew " + plural("card", "cards", count) + ": " + player.getUsername() + ", +" + count + plural(" card", " cards", count));

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(player.getNetworkID());
			bs.write_u16(count);
			getRules().SendCommand(getRules().getCommandID("draw cards"), bs, true);
		}

		if (drawPile.empty())
		{
			if (!replenishDrawPile())
			{
				warn("No more cards in the draw pile");
			}
		}

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

				print("Played card: " + player.getUsername() + ", " + card);

				if (isServer())
				{
					CBitStream bs;
					bs.write_u16(player.getNetworkID());
					bs.write_u16(card);
					getRules().SendCommand(getRules().getCommandID("play card"), bs, true);
				}

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

		print("Traded hands: " + player1.getUsername() + ", " + player2.getUsername());

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(player1.getNetworkID());
			bs.write_u16(player2.getNetworkID());
			getRules().SendCommand(getRules().getCommandID("trade hands"), bs, true);
		}

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

		print("Discarded hand: " + player.getUsername());

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(player.getNetworkID());
			getRules().SendCommand(getRules().getCommandID("discard hand"), bs, true);
		}

		return true;
	}

	void ShuffleDrawPile(uint seed = Time())
	{
		Random random(seed);

		// Durstenfeld shuffle
		// https://stackoverflow.com/a/12646864
		for (uint i = drawPile.size() - 1; i > 0; i--)
		{
			uint j = random.NextRanged(i + 1);

			u16 temp = drawPile[i];
			drawPile[i] = drawPile[j];
			drawPile[j] = temp;
		}

		print("Shuffled draw pile: " + seed + " seed");

		if (isServer())
		{
			CBitStream bs;
			bs.write_u32(random.getSeed());
			getRules().SendCommand(getRules().getCommandID("shuffle draw pile"), bs, true);
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

		print("Replenished draw pile: +" + (discardCount - 1) + plural(" card", " cards", discardCount - 1));

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("replenish draw pile"), bs, true);

			ShuffleDrawPile();
		}

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
