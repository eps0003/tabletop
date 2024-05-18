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
		None	= 0 << 12,
		Red		= 1 << 12,
		Yellow	= 2 << 12,
		Green	= 3 << 12,
		Blue	= 4 << 12
	}

	// u16: 0000 X000 0000 0000
	enum Flag
	{
		Wild	= 1 << 11
	}

	enum Mask
	{
		ID		= 0x000F,
		Value	= 0x07F0,
		Flags	= 0x0800,
		Color	= 0xF000
	}

	bool isEqual(u16 card1, u16 card2)
	{
		// Ignore selected wild colour
		if (Card::hasFlags(card1, Card::Flag::Wild))
		{
			card1 &= ~Card::Mask::Color;
		}

		if (Card::hasFlags(card2, Card::Flag::Wild))
		{
			card2 &= ~Card::Mask::Color;
		}

		return card1 == card2;
	}

	bool isNumber(u16 card)
	{
		u16 value = card & Card::Mask::Value;
		return (
			value >= Card::Value::Zero &&
			value <= Card::Value::Nine
		);
	}

	bool isValue(u16 card, Card::Value value)
	{
		return card & Card::Mask::Value == value;
	}

	bool isSameValue(u16 card1, u16 card2)
	{
		return card1 & Card::Mask::Value == card2 & Card::Mask::Value;
	}

	bool isColor(u16 card, Card::Color color)
	{
		return card & Card::Mask::Color == color;
	}

	bool isSameColor(u16 card1, u16 card2)
	{
		return card1 & Card::Mask::Color == card2 & Card::Mask::Color;
	}

	bool hasFlags(u16 card, Card::Flag flags)
	{
		return card & flags == flags;
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

		string color = colors[(card & Card::Mask::Color) >> 12];
		if (color != "")
		{
			name.push_back(color);
		}

		if (Card::hasFlags(card, Card::Flag::Wild))
		{
			name.push_back("Wild");
		}

		string value = values[(card & Card::Mask::Value) >> 4];
		if (value != "")
		{
			name.push_back(value);
		}

		return join(name, " ");
	}
}
