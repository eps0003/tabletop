#include "Hand.as"

namespace Hand
{
	void Init()
	{
		CPlayer@[] order;
		getRules().set("hand_order", order);
	}

	void AddHand(Hand@ hand)
	{
		hand.player.set("hand", @hand);
		getRules().push("hand_order", @hand.player);
	}

	void RemoveHand(CPlayer@ player)
	{
		player.set("hand", null);

		int index = Hand::getHandIndex(player);
		if (index > -1)
		{
			getRules().removeAt("hand_order", index);
		}
	}

	Hand@ getHand(CPlayer@ player)
	{
		Hand@ hand;
		player.get("hand", @hand);
		return hand;
	}

	Hand@[] getHands()
	{
		CPlayer@[] order = Hand::getHandOrder();
		Hand@[] hands;
		for (uint i = 0; i < order.size(); i++)
		{
			CPlayer@ player = order[i];
			hands.push_back(Hand::getHand(player));
		}
		return hands;
	}

	uint getHandCount()
	{
		return Hand::getHandOrder().size();
	}

	CPlayer@[] getHandOrder()
	{
		CPlayer@[] order;
		getRules().get("hand_order", order);
		return order;
	}

	int getHandIndex(CPlayer@ player)
	{
		CPlayer@[] order = Hand::getHandOrder();
		for (uint i = 0; i < order.size(); i++)
		{
			if (order[i] is player)
			{
				return i;
			}
		}
		return -1;
	}

	void RandomizeHandOrder(uint seed = Time())
	{
		Random rand(seed);

		CPlayer@[] order = Hand::getHandOrder();
		uint n = order.size();

		//https://stackoverflow.com/a/12646864
		for (int i = n - 1; i > 0; i--)
		{
			uint j = rand.NextRanged(i + 1);

			CPlayer@ tempPlayer = order[i];
			@order[i] = order[j];
			@order[j] = tempPlayer;
		}

		getRules().set("hand_order", order);
	}

	void Update()
	{
		Hand@[] hands = Hand::getHands();
		for (uint i = 0; i < hands.size(); i++)
		{
			Hand@ hand = hands[i];
			int index = Hand::getOrientedHandIndex(i);
			hand.Update(index);

		}
	}

	void Render()
	{
		Hand@[] hands = Hand::getHands();
		uint n = hands.size();

		int myIndex = Hand::getHandIndex(getLocalPlayer());
		if (myIndex < 0) return;

		for (uint i = 0; i < n; i++)
		{
			Hand@ hand = hands[i];
			uint index = Hand::getOrientedHandIndex(i);
			hand.Render(index);
		}
	}

	uint getOrientedHandIndex(uint index)
	{
		uint n = Hand::getHandCount();
		int myIndex = Hand::getHandIndex(getLocalPlayer());
		return (n + index - myIndex) % n;
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
