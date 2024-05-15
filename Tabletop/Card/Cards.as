namespace Card
{
	// u16: 0000 0XXX XXXX 0000
	// The rightmost nibble is for uniquely identifying identical cards
	enum Value
	{
		None	=  0 << 4,
		Zero	=  1 << 4,
		One		=  2 << 4,
		Two		=  3 << 4,
		Three	=  4 << 4,
		Four	=  5 << 4,
		Five	=  6 << 4,
		Six		=  7 << 4,
		Seven	=  8 << 4,
		Eight	=  9 << 4,
		Nine	= 10 << 4,
		Reverse	= 11 << 4,
		Skip	= 12 << 4,
		Draw2	= 13 << 4,
		Draw4	= 14 << 4
	}

	// u16: XXXX 0000 0000 0000
	enum Color
	{
		Wild	= Card::Flag::Wild,
		Red		= 1 << 12,
		Yellow	= 2 << 12,
		Green	= 3 << 12,
		Blue	= 4 << 12,
	}

	// u16: 0000 X000 0000 0000
	enum Flag
	{
		Wild	= 1 << 11,
	}

	bool isEqual(u16 card1, u16 card2)
	{
		// Ignore selected wild colour
		if (Card::isFlag(card1, Card::Flag::Wild))
		{
			card1 &= ~0xF000;
		}

		if (Card::isFlag(card2, Card::Flag::Wild))
		{
			card2 &= ~0xF000;
		}

		return card1 == card2;
	}

	bool isNumber(u16 card)
	{
		u16 value = card & 0x07F0;
		return (
			value >= Card::Value::Zero &&
			value <= Card::Value::Nine
		);
	}

	bool isValue(u16 card, Card::Value value)
	{
		return card & 0x07F0 == value;
	}

	bool isSameValue(u16 card1, u16 card2)
	{
		return card1 & 0x07F0 == card2 & 0x07F0;
	}

	bool isColor(u16 card, Card::Color color)
	{
		return card & 0xF000 == color;
	}

	bool isSameColor(u16 card1, u16 card2)
	{
		return card1 & 0xF000 == card2 & 0xF000;
	}

	bool isFlag(u16 card, Card::Flag flag)
	{
		return card & flag == flag;
	}

	string getName(u16 card)
	{
		string[] colors = {
			"", // Undecided wild
			"Red",
			"Yellow",
			"Green",
			"Blue"
		};

		string[] values = {
			"",
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
			"⇌", "↷",
			"+2", "+4"
		};

		string[] name;

		string color = colors[(card & 0xF000) >> 12];
		if (color != "")
		{
			name.push_back(color);
		}

		if (Card::isFlag(card, Card::Flag::Wild))
		{
			name.push_back("Wild");
		}

		string value = values[(card & 0x07F0) >> 4];
		if (value != "")
		{
			name.push_back(value);
		}

		return join(name, " ");
	}
}
