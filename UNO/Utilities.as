bool isReady()
{
	return getLocalPlayer() !is null && getRules().get_bool("ready");
}

void SetReady(bool ready)
{
	getRules().set_bool("ready", ready);
}

float angleDifference(float angle1, float angle2)
{
	//https://stackoverflow.com/a/28037434
	float diff = (angle1 - angle2 + 180) % 360 - 180;
	return diff < -180 ? diff + 360 : diff;
}
