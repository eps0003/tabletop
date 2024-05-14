#include "Cards.as"
#include "Utilities.as"

const u16 STARTING_HAND_SIZE = 7;

class Game
{
	private CPlayer@[] players;
	private dictionary hands;

	private u16[] drawPile = {
		Card::Color::Red | Card::Value::Zero | 0,
		Card::Color::Red | Card::Value::One | 0,
		Card::Color::Red | Card::Value::One | 1,
		Card::Color::Red | Card::Value::Two | 0,
		Card::Color::Red | Card::Value::Two | 1,
		Card::Color::Red | Card::Value::Three | 0,
		Card::Color::Red | Card::Value::Three | 1,
		Card::Color::Red | Card::Value::Four | 0,
		Card::Color::Red | Card::Value::Four | 1,
		Card::Color::Red | Card::Value::Five | 0,
		Card::Color::Red | Card::Value::Five | 1,
		Card::Color::Red | Card::Value::Six | 0,
		Card::Color::Red | Card::Value::Six | 1,
		Card::Color::Red | Card::Value::Seven | 0,
		Card::Color::Red | Card::Value::Seven | 1,
		Card::Color::Red | Card::Value::Eight | 0,
		Card::Color::Red | Card::Value::Eight | 1,
		Card::Color::Red | Card::Value::Nine | 0,
		Card::Color::Red | Card::Value::Nine | 1,
		Card::Color::Red | Card::Value::Nine | 0,
		Card::Color::Red | Card::Value::Reverse | 0,
		Card::Color::Red | Card::Value::Reverse | 1,
		Card::Color::Red | Card::Value::Skip | 0,
		Card::Color::Red | Card::Value::Skip | 1,
		Card::Color::Red | Card::Value::Draw2 | 0,
		Card::Color::Red | Card::Value::Draw2 | 1,

		Card::Color::Yellow | Card::Value::Zero | 0,
		Card::Color::Yellow | Card::Value::One | 0,
		Card::Color::Yellow | Card::Value::One | 1,
		Card::Color::Yellow | Card::Value::Two | 0,
		Card::Color::Yellow | Card::Value::Two | 1,
		Card::Color::Yellow | Card::Value::Three | 0,
		Card::Color::Yellow | Card::Value::Three | 1,
		Card::Color::Yellow | Card::Value::Four | 0,
		Card::Color::Yellow | Card::Value::Four | 1,
		Card::Color::Yellow | Card::Value::Five | 0,
		Card::Color::Yellow | Card::Value::Five | 1,
		Card::Color::Yellow | Card::Value::Six | 0,
		Card::Color::Yellow | Card::Value::Six | 1,
		Card::Color::Yellow | Card::Value::Seven | 0,
		Card::Color::Yellow | Card::Value::Seven | 1,
		Card::Color::Yellow | Card::Value::Eight | 0,
		Card::Color::Yellow | Card::Value::Eight | 1,
		Card::Color::Yellow | Card::Value::Nine | 0,
		Card::Color::Yellow | Card::Value::Nine | 1,
		Card::Color::Yellow | Card::Value::Nine | 0,
		Card::Color::Yellow | Card::Value::Reverse | 0,
		Card::Color::Yellow | Card::Value::Reverse | 1,
		Card::Color::Yellow | Card::Value::Skip | 0,
		Card::Color::Yellow | Card::Value::Skip | 1,
		Card::Color::Yellow | Card::Value::Draw2 | 0,
		Card::Color::Yellow | Card::Value::Draw2 | 1,

		Card::Color::Green | Card::Value::Zero | 0,
		Card::Color::Green | Card::Value::One | 0,
		Card::Color::Green | Card::Value::One | 1,
		Card::Color::Green | Card::Value::Two | 0,
		Card::Color::Green | Card::Value::Two | 1,
		Card::Color::Green | Card::Value::Three | 0,
		Card::Color::Green | Card::Value::Three | 1,
		Card::Color::Green | Card::Value::Four | 0,
		Card::Color::Green | Card::Value::Four | 1,
		Card::Color::Green | Card::Value::Five | 0,
		Card::Color::Green | Card::Value::Five | 1,
		Card::Color::Green | Card::Value::Six | 0,
		Card::Color::Green | Card::Value::Six | 1,
		Card::Color::Green | Card::Value::Seven | 0,
		Card::Color::Green | Card::Value::Seven | 1,
		Card::Color::Green | Card::Value::Eight | 0,
		Card::Color::Green | Card::Value::Eight | 1,
		Card::Color::Green | Card::Value::Nine | 0,
		Card::Color::Green | Card::Value::Nine | 1,
		Card::Color::Green | Card::Value::Nine | 0,
		Card::Color::Green | Card::Value::Reverse | 0,
		Card::Color::Green | Card::Value::Reverse | 1,
		Card::Color::Green | Card::Value::Skip | 0,
		Card::Color::Green | Card::Value::Skip | 1,
		Card::Color::Green | Card::Value::Draw2 | 0,
		Card::Color::Green | Card::Value::Draw2 | 1,

		Card::Color::Blue | Card::Value::Zero | 0,
		Card::Color::Blue | Card::Value::One | 0,
		Card::Color::Blue | Card::Value::One | 1,
		Card::Color::Blue | Card::Value::Two | 0,
		Card::Color::Blue | Card::Value::Two | 1,
		Card::Color::Blue | Card::Value::Three | 0,
		Card::Color::Blue | Card::Value::Three | 1,
		Card::Color::Blue | Card::Value::Four | 0,
		Card::Color::Blue | Card::Value::Four | 1,
		Card::Color::Blue | Card::Value::Five | 0,
		Card::Color::Blue | Card::Value::Five | 1,
		Card::Color::Blue | Card::Value::Six | 0,
		Card::Color::Blue | Card::Value::Six | 1,
		Card::Color::Blue | Card::Value::Seven | 0,
		Card::Color::Blue | Card::Value::Seven | 1,
		Card::Color::Blue | Card::Value::Eight | 0,
		Card::Color::Blue | Card::Value::Eight | 1,
		Card::Color::Blue | Card::Value::Nine | 0,
		Card::Color::Blue | Card::Value::Nine | 1,
		Card::Color::Blue | Card::Value::Reverse | 0,
		Card::Color::Blue | Card::Value::Reverse | 1,
		Card::Color::Blue | Card::Value::Skip | 0,
		Card::Color::Blue | Card::Value::Skip | 1,
		Card::Color::Blue | Card::Value::Draw2 | 0,
		Card::Color::Blue | Card::Value::Draw2 | 1,

		Card::Color::Wild | Card::Value::Draw4 | 0,
		Card::Color::Wild | Card::Value::Draw4 | 1,
		Card::Color::Wild | Card::Value::Draw4 | 2,
		Card::Color::Wild | Card::Value::Draw4 | 3,
		Card::Color::Wild | 0,
		Card::Color::Wild | 1,
		Card::Color::Wild | 2,
		Card::Color::Wild | 3
	};
	private u16[] discardPile;

	private bool pendingAction = false;

	private CPlayer@ turnPlayer;
	private s8 turnDirection = 1;

	Game(CPlayer@[] players, uint seed = Time())
	{
		this.players = players;

		print("Started game: " + players.size() + plural(" player", " players", players.size()));

		if (players.empty())
		{
			warn("Game was instantiated with no players");
		}
		else
		{
			@turnPlayer = players[0];
		}

		ShuffleDrawPile(seed);

		// Start with a number card in the discard pile
		for (int i = drawPile.size() - 1; i >= 0; i--)
		{
			u16 card = drawPile[i];
			if (Card::isNumber(card))
			{
				drawPile.removeAt(i);
				discardPile.push_back(card);
				break;
			}
		}

		for (uint i = 0; i < players.size(); i++)
		{
			u16[] hand;

			for (uint j = 0; j < STARTING_HAND_SIZE; j++)
			{
				u16 index = drawPile.size() - 1;
				u16 card = drawPile[index];

				drawPile.removeAt(index);
				hand.push_back(card);
			}

			hands.set(players[i].getUsername(), hand);
		}

		if (isServer())
		{
			CBitStream bs;
			bs.write_u32(seed);
			bs.write_u16(players.size());

			for (uint i = 0; i < players.size(); i++)
			{
				bs.write_u16(players[i].getNetworkID());
			}

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

		if (!saferead_player(bs, @turnPlayer)) return;
		if (!bs.saferead_s8(turnDirection)) return;

		print("Deserialized game");
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

		bs.write_u16(turnPlayer.getNetworkID());
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
		return turnPlayer;
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

	void RemovePlayer(CPlayer@ player, bool sync = true)
	{
		for (uint i = 0; i < players.size(); i++)
		{
			CPlayer@ otherPlayer = players[i];
			if (player is otherPlayer)
			{
				u16[]@ hand;
				hands.get(player.getUsername(), @hand);

				// Discard hand to the bottom of the discard pile
				for (int i = hand.size() - 1; i >= 0; i--)
				{
					discardPile.insertAt(0, hand[i]);
				}

				if (player is turnPlayer && players.size() > 1)
				{
					NextTurn(sync);
				}

				players.removeAt(i);
				hands.delete(player.getUsername());

				print("Removed player: " + player.getUsername());

				if (isServer())
				{
					if (sync)
					{
						CBitStream bs;
						bs.write_u16(player.getNetworkID());
						getRules().SendCommand(getRules().getCommandID("remove player"), bs, true);
					}

					if (players.size() == 0)
					{
						End();
					}
				}

				break;
			}
		}
	}

	void NextTurn(bool sync = true)
	{
		for (uint i = 0; i < players.size(); i++)
		{
			if (players[i] is turnPlayer)
			{
				u16 turnIndex = (i + turnDirection) % players.size();
				@turnPlayer = players[turnIndex];

				print("Next turn: " + turnPlayer.getUsername());

				if (isServer() && sync)
				{
					CBitStream bs;
					getRules().SendCommand(getRules().getCommandID("next turn"), bs, true);
				}

				break;
			}
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
		return turnPlayer !is null && turnPlayer is player;
	}

	bool drawCards(CPlayer@ player)
	{
		if (!canDrawCards(player))
		{
			return false;
		}

		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		u16 count = getCardsToDraw(player);

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
		if (!canPlayCard(player, card))
		{
			return false;
		}

		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		if (hand is null)
		{
			return false;
		}

		for (int i = hand.size() - 1; i >= 0; i--)
		{
			u16 handCard = hand[i];

			if (Card::isEqual(handCard, card))
			{
				hand.removeAt(i);
				discardPile.push_back(card);

				print("Played card: " + player.getUsername() + ", " + handCard);

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

	bool swapHands(CPlayer@ player1, CPlayer@ player2)
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

		print("Swapped hands: " + player1.getUsername() + ", " + player2.getUsername());

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(player1.getNetworkID());
			bs.write_u16(player2.getNetworkID());
			getRules().SendCommand(getRules().getCommandID("swap hands"), bs, true);
		}

		return true;
	}

	// FIXME: Achieve true determinism by only randomizing on server and syncing entire draw pile to clients
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
			bs.write_u32(seed);
			getRules().SendCommand(getRules().getCommandID("shuffle draw pile"), bs, true);
		}
	}

	private bool replenishDrawPile()
	{
		uint discardCount = discardPile.size();

		if (discardCount < 2)
		{
			return false;
		}

		for (uint i = 0; i < discardCount - 1; i++)
		{
			u16 card = discardPile[i];

			// Remove selected colour
			if (Card::isFlag(card, Card::Flag::Wild))
			{
				card &= ~0xF000;
			}

			drawPile.push_back(card);
		}

		u16 topDiscardCard = discardPile[discardCount - 1];
		discardPile.clear();
		discardPile.push_back(topDiscardCard);

		print("Replenished draw pile: +" + (discardCount - 1) + plural(" card", " cards", discardCount - 1));

		return true;
	}

	bool playerHasCard(CPlayer@ player, u16 card)
	{
		u16[] hand = getHand(player);

		for (uint i = 0; i < hand.size(); i++)
		{
			u16 handCard = hand[i];

			if (Card::isEqual(handCard, card))
			{
				return true;
			}
		}

		return false;
	}

	bool canPlayCard(CPlayer@ player, u16 card)
	{
		if (!isPlayersTurn(player) || !playerHasCard(player, card))
		{
			return false;
		}

		u16 topCard = discardPile[discardPile.size() - 1];
		return (
			topCard & 0x07F0 == card & 0x07F0 || // Same value
			topCard & 0xF000 == card & 0xF000 || // Same color
			Card::isFlag(card, Card::Flag::Wild) // Wild card
		);
	}

	bool canDrawCards(CPlayer@ player)
	{
		return getCardsToDraw(player) > 0;
	}

	u16 getCardsToDraw(CPlayer@ player)
	{
		// Not the player's turn
		if (!isPlayersTurn(player))
		{
			return 0;
		}

		if (pendingAction)
		{
			u16 topCard = discardPile[discardPile.size() - 1];

			// Pick up draw 2
			if (Card::isValue(topCard, Card::Value::Draw2))
			{
				return 2;
			}

			// Pick up draw 4
			if (Card::isValue(topCard, Card::Value::Draw4))
			{
				return 4;
			}
		}

		return 1;
	}

	void End()
	{
		print("Ended game");

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("end game"), bs, true);
		}

		GameManager::Set(null);
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
