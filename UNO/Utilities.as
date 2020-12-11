bool isReady()
{
	return getLocalPlayer() !is null && getRules().get_bool("ready");
}

void SetReady(bool ready)
{
	getRules().set_bool("ready", ready);
}
