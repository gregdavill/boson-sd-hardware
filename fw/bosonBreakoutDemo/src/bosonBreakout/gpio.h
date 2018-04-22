#pragma once

#include "sam.h"

template <uint32_t pin> struct SamPin {
	static PortGroup* port() { return &PORT->Group[pin / 32]; }

	static void Set() { port()->OUTSET.reg = (1 << (pin % 32)); }
	static void Clear() { port()->OUTCLR.reg = (1 << (pin % 32)); }
	static void Toggle() { port()->OUTTGL.reg = (1 << (pin % 32)); }

	static void Dir(bool value)
	{
		if (value == true) {
			port()->DIRSET.reg = (1 << (pin % 32));
		} else {
			port()->DIRCLR.reg = (1 << (pin % 32));
		}
	}

	static void InputEn(bool value)
	{
		if (value)
			port()->PINCFG[pin % 32].reg |= PORT_PINCFG_INEN | PORT_PINCFG_PULLEN;
		else
			port()->PINCFG[pin % 32].reg &= ~(PORT_PINCFG_INEN | PORT_PINCFG_PULLEN);
	}
	static void MuxEn(bool value)
	{
		if (value)
			port()->PINCFG[pin % 32].reg |= PORT_PINCFG_PMUXEN;
		else
			port()->PINCFG[pin % 32].reg &= ~PORT_PINCFG_PMUXEN;
	}

	static void Mux(uint32_t mux)
	{
		if (pin % 2 == 0) {
			port()->PMUX[(pin % 32) / 2].reg &= ~PORT_PMUX_PMUXE_Msk;
			port()->PMUX[(pin % 32) / 2].reg |= PORT_PMUX_PMUXE(mux);
		} else {
			port()->PMUX[(pin % 32) / 2].reg &= ~PORT_PMUX_PMUXO_Msk;
			port()->PMUX[(pin % 32) / 2].reg |= PORT_PMUX_PMUXO(mux);
		}
	}
};