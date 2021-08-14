extends Label

func on_received_payment(_amt, total):
	text = "MONEY: %s$" % total
