#include "Cards.as"
#include "OfficialRuleset.as"
#include "Utilities.as"

const u16 STARTING_HAND_SIZE = 7;

class Game
{
	private CPlayer@[] players;
	private dictionary hands;

	Ruleset@ ruleset;

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

	Game(CPlayer@[] players, Ruleset@ ruleset, uint seed = Time())
	{
		this.players = players;
		@this.ruleset = ruleset;

		if (players.empty())
		{
			warn("Started game: 0 players");
		}
		else
		{
			print("Started game: " + players.size() + plural(" player", " players", players.size()));

			@turnPlayer = players[0];
		}

		ShuffleCards(drawPile, seed);

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

			// TODO: Move this into GameManager::set()
			getRules().SendCommand(getRules().getCommandID("init game"), bs, true);
		}

		ruleset.OnStart(this, players);
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
		ruleset.OnSync(this, getLocalPlayer());
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

			u16[] hand;
			getHand(gamePlayer, hand);
			SerialiseCards(bs, hand);
		}

		SerialiseCards(bs, drawPile);
		SerialiseCards(bs, discardPile);

		bs.write_u16(turnPlayer.getNetworkID());
		bs.write_s8(turnDirection);

		getRules().SendCommand(getRules().getCommandID("sync game"), bs, player);

		print("Synced game: " + player.getUsername());
		ruleset.OnSync(this, player);
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

	bool getHand(CPlayer@ player, u16[] &out hand)
	{
		if (player is null)
		{
			return false;
		}

		hands.get(player.getUsername(), hand);
		return true;
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

				if (isServer())
				{
					if (sync)
					{
						CBitStream bs;
						bs.write_u16(player.getNetworkID());
						getRules().SendCommand(getRules().getCommandID("remove player"), bs, true);
					}
				}

				print("Removed player: " + player.getUsername());
				ruleset.OnLeave(this, player);

				if (isServer() && players.size() == 0)
				{
					End();
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

				if (isServer() && sync)
				{
					CBitStream bs;
					getRules().SendCommand(getRules().getCommandID("next turn"), bs, true);
				}

				print("Next turn: " + turnPlayer.getUsername());
				ruleset.OnNextTurn(this, players[i], turnPlayer);

				break;
			}
		}
	}

	void SkipTurn()
	{
		for (uint i = 0; i < players.size(); i++)
		{
			if (players[i] is turnPlayer)
			{
				u16 skippedTurnIndex = (i + turnDirection) % players.size();
				CPlayer@ skippedTurnPlayer = players[skippedTurnIndex];

				u16 turnIndex = (i + turnDirection * 2) % players.size();
				@turnPlayer = players[turnIndex];

				if (isServer())
				{
					CBitStream bs;
					getRules().SendCommand(getRules().getCommandID("skip turn"), bs, true);
				}

				print("Skip turn: " + skippedTurnPlayer.getUsername());
				ruleset.OnSkipTurn(this, skippedTurnPlayer);

				print("Next turn: " + turnPlayer.getUsername());
				ruleset.OnNextTurn(this, players[i], turnPlayer);

				break;
			}
		}
	}

	void ReverseDirection()
	{
		turnDirection *= -1;

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("reverse direction"), bs, true);
		}

		print("Reversed direction: " + turnDirection);
		ruleset.OnReverseDirection(this, turnDirection);
	}

	bool isPlayersTurn(CPlayer@ player)
	{
		return turnPlayer !is null && turnPlayer is player;
	}

	void DrawCard()
	{
		if (!ruleset.canDrawCard(this, turnPlayer)) return;

		u16[]@ hand;
		hands.get(turnPlayer.getUsername(), @hand);

		uint index = drawPile.size() - 1;
		u16 card = drawPile[index];

		drawPile.removeAt(index);
		hand.push_back(card);

		if (isServer())
		{
			CBitStream bs;
			// Optional
			bs.write_u16(turnPlayer.getNetworkID());
			bs.write_u16(card);
			getRules().SendCommand(getRules().getCommandID("draw card"), bs, true);
		}

		print("Drew card: " + turnPlayer.getUsername());
		ruleset.OnDrawCard(this, turnPlayer, card);
	}

	void PlayCard(CPlayer@ player, u16 card)
	{
		if (!canPlayCard(player, card)) return;

		u16[]@ hand;
		hands.get(player.getUsername(), @hand);

		for (int i = hand.size() - 1; i >= 0; i--)
		{
			u16 handCard = hand[i];

			if (Card::isEqual(handCard, card))
			{
				hand.removeAt(i);
				discardPile.push_back(card);

				if (isServer())
				{
					CBitStream bs;
					bs.write_u16(player.getNetworkID());
					bs.write_u16(card);
					getRules().SendCommand(getRules().getCommandID("play card"), bs, true);
				}

				print("Played card: " + player.getUsername() + ", " + handCard);
				ruleset.OnPlayCard(this, turnPlayer, card);
			}
		}
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

		if (isServer())
		{
			CBitStream bs;
			bs.write_u16(player1.getNetworkID());
			bs.write_u16(player2.getNetworkID());
			getRules().SendCommand(getRules().getCommandID("swap hands"), bs, true);
		}

		print("Swapped hands: " + player1.getUsername() + ", " + player2.getUsername());
		ruleset.OnSwapHands(this, player1, player2);

		return true;
	}

	// FIXME: Achieve true determinism by only randomizing on server and syncing entire draw pile to clients
	void ShuffleCards(u16[]@ cards, uint seed = Time())
	{
		Random random(seed);

		// Durstenfeld shuffle
		// https://stackoverflow.com/a/12646864
		for (uint i = cards.size() - 1; i > 0; i--)
		{
			uint j = random.NextRanged(i + 1);

			u16 temp = cards[i];
			cards[i] = cards[j];
			cards[j] = temp;
		}

		print("Shuffled cards: " + seed + " seed");
	}

	void ReplenishDrawPile()
	{
		int replenishCount = discardPile.size() - 1;
		if (replenishCount <= 0) return;

		for (uint i = 0; i < replenishCount; i++)
		{
			u16 card = discardPile[i];

			// Remove selected colour
			if (Card::hasFlags(card, Card::Flag::Wild))
			{
				card &= ~Card::Mask::Color;
			}

			drawPile.push_back(card);
		}

		u16 topDiscardCard = discardPile[replenishCount];
		discardPile.clear();
		discardPile.push_back(topDiscardCard);

		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("replenish draw pile"), bs, true);
		}

		print("Replenished draw pile: +" + replenishCount + plural(" card", " cards", replenishCount));
		ruleset.OnReplenishDrawPile(this);
	}

	bool playerHasCard(CPlayer@ player, u16 card)
	{
		u16[] hand;

		if (!getHand(player, hand))
		{
			return false;
		}

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

		return ruleset.canPlayCard(this, player, card);
	}

	void End()
	{
		if (isServer())
		{
			CBitStream bs;
			getRules().SendCommand(getRules().getCommandID("end game"), bs, true);
		}

		print("Ended game");
		ruleset.OnEnd(this);

		GameManager::Set(null);
	}
}

// TODO: Rename to Game
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
