#include "HandManager.as"

namespace Turn
{
	void SetTurn(int index)
	{
		uint n = Hand::getHandCount();
		getRules().set_u8("turn_index", index % n);
	}

	void SetTurn(CPlayer@ player)
	{
		Hand@[] hands = Hand::getHands();
		for (uint i = 0; i < hands.size(); i++)
		{
			Hand@ hand = hands[i];
			if (hand.player is player)
			{
				Turn::SetTurn(i);
			}
		}
	}

	u8 getTurnIndex()
	{
		return getRules().get_u8("turn_index");
	}

	CPlayer@ getTurn()
	{
		Hand@[] hands = Hand::getHands();
		u8 index = Turn::getTurnIndex();
		return hands[index].player;
	}

	bool isMyTurn()
	{
		return Turn::getTurn().isMyPlayer();
	}

	void SetDirection(s8 dir)
	{
		dir = dir >= 0 ? 1 : -1;
		getRules().set_s8("turn_direction", dir);
	}

	s8 getDirection()
	{
		return getRules().get_s8("turn_direction");
	}

	void ReverseDirection()
	{
		s8 dir = Turn::getDirection();
		Turn::SetDirection(dir * -1);
	}

	void NextTurn()
	{
		u8 index = Turn::getTurnIndex();
		s8 dir = Turn::getDirection();
		Turn::SetTurn(index + dir);
	}
}
