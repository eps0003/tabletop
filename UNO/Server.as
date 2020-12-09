#define SERVER_ONLY

void onInit(CRules@ this)
{
	onRestart();
}

void onRestart()
{

}

void onTick(CRules@ this)
{

}

void onCommand(CRules@ this, u8 cmd, CBitStream@ params)
{
	if (cmd == this.getCommandID("c_reset"))
	{
		LoadNextMap();
	}
}
