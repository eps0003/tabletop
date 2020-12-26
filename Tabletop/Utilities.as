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

float smallestScreenDim()
{
	Vec2f screenDim = getDriver().getScreenDimensions();
	return Maths::Min(screenDim.x, screenDim.y);
}

//get the value to scale current with to reach target
float getScalar(float current, float target)
{
	return current != 0 ? target / current : 0;
}
