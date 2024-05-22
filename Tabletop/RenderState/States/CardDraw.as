#include "SequentialState.as"
#include "CardLerp.as"
#include "CardFlip.as"

class CardDraw : SequentialState
{
	private Game@ game;
	private dictionary@ renderCards;

	CardDraw(Game@ game, dictionary@ renderCards)
	{
		@this.game = game;
		@this.renderCards = renderCards;
	}

	void Start()
	{
		u16 card = game.drawCard();

		RenderCard@ renderCard;
		renderCards.get("" + Card::clean(card), @renderCard);

		Add(CardLerp(game, renderCard));
	}
}
