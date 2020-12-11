#include "Stack.as"

namespace Stack
{
	void Init()
	{
		CRules@ rules = getRules();

		Stack@[] stacks;
		rules.set("stacks", stacks);

		dictionary stackMap;
		rules.set("stack_map", stackMap);
	}

	void AddStack(string name, Stack@ stack)
	{
		CRules@ rules = getRules();

		Stack@[]@ stacks;
		rules.get("stacks", @stacks);
		stacks.push_back(@stack);

		dictionary stackMap;
		rules.get("stack_map", stackMap);
		stackMap.set(name, @stack);
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

	Stack@[] getStacks()
	{
		Stack@[] stacks;
		getRules().get("stacks", stacks);
		return stacks;
	}

	void Serialize(CBitStream@ bs)
	{
		dictionary stackMap;
		getRules().get("stack_map", stackMap);

		string[]@ stackKeys = stackMap.getKeys();
		uint n = stackKeys.size();

		bs.write_u16(n);

		for (uint i = 0; i < n; i++)
		{
			string key = stackKeys[i];
			Stack@ stack = Stack::getStack(key);

			bs.write_string(key);
			stack.Serialize(bs);
		}
	}
}
