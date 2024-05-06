class TurnManager
{
	private CPlayer@[] players;
	private uint index = 0;
	private s8 direction = 1;

	void SetPlayers(CPlayer@[] players)
	{
		this.players = players;
		index = 0;
	}

	CPlayer@[] getPlayers()
	{
		return players;
	}

	CPlayer@ getPlayer()
	{
		return players.empty() ? null : players[index];
	}

	void NextPlayer()
	{
		if (players.size() > 0)
		{
			index = (int(index) + direction) % players.size();
		}
	}

	void PrevPlayer()
	{
		if (players.size() > 0)
		{
			index = (int(index) - direction) % players.size();
		}
	}

	void SetReverse(bool reverse)
	{
		direction = reverse ? -1 : 1;
	}

	bool isReverse()
	{
		return direction == -1;
	}

	void FlipDirection()
	{
		direction *= -1;
	}

	bool isMyTurn()
	{
		CPlayer@ player = getPlayer();
		return player !is null && player.isMyPlayer();
	}

	bool isEmpty()
	{
		return players.empty();
	}
}

namespace TurnManager
{
	TurnManager@ get()
	{
		TurnManager@ turns;
		if (!getRules().get("turns", @turns))
		{
			@turns = TurnManager();
			getRules().set("turns", @turns);
		}
		return turns;
	}
}
