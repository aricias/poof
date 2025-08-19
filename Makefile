mudlet_profile := "$$HOME/.config/mudlet/profiles/discworld"


default: moot.mpackage

dev:
	rm -rf $(mudlet_profile)/moot
	cp -r moot $(mudlet_profile)
	# cp $(mudlet_profile)/Database_npcs.db moot/

moot.mpackage: 
	cd moot && zip ../$@ -r .

clean:
	rm moot.mpackage
