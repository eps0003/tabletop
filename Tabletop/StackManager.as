#include "Stack.as"
#include "Utilities.as"

namespace Stack
{
	void Init()
	{
		CRules@ rules = getRules();

		dictionary stackMap;
		rules.set("stack_map", stackMap);
	}

	void AddStack(Stack@ stack)
	{
		CRules@ rules = getRules();

		dictionary stackMap;
		rules.get("stack_map", stackMap);
		stackMap.set(stack.name, @stack);
		rules.set("stack_map", stackMap);
	}

	Stack@ getStack(string name)
	{
		dictionary stackMap;
		getRules().get("stack_map", stackMap);

		Stack@ stack;
		stackMap.get(name, @stack);
		return stack;
	}

	Stack@ getNearestStack(Vec2f point, float &out len)
	{
		Stack@ nearest;

		Stack@[] stacks = Stack::getStacks();
		for (uint i = 0; i < stacks.size(); i++)
		{
			Stack@ stack = stacks[i];
			Card@ topCard = stack.getTopCard();

			Vec2f pos = topCard !is null ? topCard.position : stack.position;
			Vec2f offset = point - pos;
			float thisLen = Maths::Sqrt(offset.x * offset.x + offset.y * offset.y);

			if (i == 0 || thisLen < len)
			{
				@nearest = stack;
				len = thisLen;
			}
		}

		return nearest;
	}

	Stack@[] getStacks()
	{
		dictionary stackMap;
		getRules().get("stack_map", stackMap);

		Stack@[] stacks;
		string[]@ stackKeys = stackMap.getKeys();
		for (uint i = 0; i < stackKeys.size(); i++)
		{
			string key = stackKeys[i];
			stacks.push_back(Stack::getStack(key));
		}
		return stacks;
	}

	void Render()
	{
		Stack@[] stacks = Stack::getStacks();
		for (uint i = 0; i < stacks.size(); i++)
		{
			stacks[i].Render();
		}
	}

	void Serialize(CBitStream@ bs)
	{
		Stack@[] stacks = Stack::getStacks();

		uint n = stacks.size();
		bs.write_u16(n);

		for (uint i = 0; i < n; i++)
		{
			stacks[i].Serialize(bs);
		}
	}

	void Deserialize(CBitStream@ bs)
	{
		Vec2f screenCenter = getDriver().getScreenCenterPos();

		u16 n = bs.read_u16();
		for (uint i = 0; i < n; i++)
		{
			Stack@ stack = Stack(bs);

			stack.position = screenCenter + stack.position * smallestScreenDim();
			for (uint i = 0; i < stack.cards.size(); i++)
			{
				Card@ card = stack.cards[i];
				card.position = stack.position;
				card.targetPosition = stack.position;
			}

			Stack::AddStack(stack);
		}
	}
}
