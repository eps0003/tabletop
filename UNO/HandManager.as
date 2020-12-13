#include "Hand.as"

namespace Hand
{
	void Init()
	{
		Hand@[] hands;
		getRules().set("hands", hands);
	}

	void AddHand(Hand@ hand)
	{
		hand.player.set("hand", @hand);
		getRules().push("hands", @hand);
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
		getRules().get("hands", hands);
		return hands;
	}

	void RandomizeHandOrder(uint seed = Time())
	{
		Random rand(seed);

		Hand@[] hands = Hand::getHands();
		uint n = hands.size();

		//https://stackoverflow.com/a/12646864
		for (int i = n - 1; i > 0; i--)
		{
			uint j = rand.NextRanged(i + 1);

			Hand@ temphand = hands[i];
			@hands[i] = hands[j];
			@hands[j] = temphand;
		}

		getRules().set("hands", hands);
	}

	void Render()
	{
		Hand@[] hands = Hand::getHands();
		uint n = hands.size();

		//get index of my hand
		uint myIndex = 0;
		for (uint i = 0; i < n; i++)
		{
			Hand@ hand = hands[i];
			if (hand.player.isMyPlayer())
			{
				myIndex = i;
				break;
			}
		}

		for (uint i = 0; i < n; i++)
		{
			Hand@ hand = hands[i];

			uint index = (n + i - myIndex) % n;
			hand.Render(index);
		}
	}

	void Serialize(CBitStream@ bs)
	{
		Hand@[] hands = Hand::getHands();

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
