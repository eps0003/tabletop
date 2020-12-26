namespace Deck
{
	void AddDeck(Deck@ deck)
	{
		getRules().set(deck.name, @deck);
	}

	Deck@ getDeck(string name)
	{
		Deck@ deck;
		getRules().get(name, @deck);
		return deck;
	}

	Deck@ Deserialize(CBitStream@ bs)
	{
		string name = bs.read_string();
		return Deck::getDeck(name);
	}
}
