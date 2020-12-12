#include "Stack.as"

namespace Stack
{
	void Init()
	{
		CRules@ rules = getRules();

		dictionary stackMap;
		rules.set("stack_map", stackMap);
	}

	void AddStack(string name, Stack@ stack)
	{
		CRules@ rules = getRules();

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
