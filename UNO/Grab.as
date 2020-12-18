#include "Card.as"

namespace Grab
{
	void Grab(Card@ card)
	{
		CRules@ rules = getRules();
		rules.set("grab_card", @card);
		Vec2f mousePos = getControls().getMouseScreenPos();
		rules.set_Vec2f("grab_offset", mousePos - card.position);
	}

	void Drop()
	{
		getRules().set("grab_card", null);
	}

	Card@ getGrabbed()
	{
		CRules@ rules = getRules();
		Card@ grabCard;
		rules.get("grab_card", @grabCard);
		return grabCard;
	}

	Vec2f getGrabbedPosition()
	{
		Vec2f mousePos = getControls().getInterpMouseScreenPos();
		Vec2f offset = getRules().get_Vec2f("grab_offset");
		return mousePos - offset;
	}

	bool isGrabbing(Card@ card)
	{
		CRules@ rules = getRules();
		Card@ grabCard;
		return rules.get("grab_card", @grabCard) && grabCard is card;
	}


	bool isGrabbing()
	{
		CRules@ rules = getRules();
		Card@ grabCard;
		return rules.get("grab_card", @grabCard);
	}
}
