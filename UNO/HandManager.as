#include "Hand.as"

namespace Hand
{
	void AddHand(Hand@ hand)
	{
		hand.player.set("hand", @hand);
	}

	Hand@ getHand(CPlayer@ player)
	{
		Hand@ hand;
		player.get("hand", @hand);
		return hand;
	}

	Hand@[] getHands()
	{
		Hand@[] hands;

		for (uint i = 0; i < getPlayerCount(); i++)
		{
			CPlayer@ player = getPlayer(i);
			if (player is null) continue;

			Hand@ hand = Hand::getHand(player);
			if (hand is null) continue;

			hands.push_back(hand);
		}

		return hands;
	}

	void Serialize(CBitStream@ bs)
	{
		Hand@[] hands = getHands();

		uint n = hands.size();
		bs.write_u16(n);

		for (uint i = 0; i < n; i++)
		{
			hands[i].Serialize(bs);
		}
	}

	void Deserialize(CBitStream@ bs)
	{
		u16 handCount = bs.read_u16();
		for (uint i = 0; i < handCount; i++)
		{
			Hand::AddHand(Hand(bs));
		}
	}
}
