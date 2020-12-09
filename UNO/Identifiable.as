shared class Identifiable
{
	private uint id;

	Identifiable(CBitStream@ bs)
	{
		id = bs.read_u32();
	}

	void Serialize(CBitStream@ bs)
	{
		bs.write_u32(id);
	}

	void opAssign(Identifiable identifiable)
	{
		id = identifiable.id;
	}

	uint getID()
	{
		return id;
	}

	void AssignUniqueID()
	{
		if (isServer())
		{
			id = getRules().add_u32("current_id", 1);
		}
	}
}
