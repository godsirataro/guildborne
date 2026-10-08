--!strict
-- Local art directions. Zero product IDs deliberately disable all paid fulfillment.
return {
    Order={"human","elf","dwarf","orc","mage","crosshaven"},
    Themes={
        human={Name="Human Hearth",Mode="Free",Style="Timber",Body={150,111,72},Roof={131,58,63},Accent={224,190,113}},
        elf={Name="Elven Canopy",Mode="Purchase",ProductId=0,Style="Canopy",Body={189,177,132},Roof={47,129,94},Accent={231,196,109}},
        dwarf={Name="Dwarven Forge",Mode="Purchase",ProductId=0,Style="Forge",Body={86,96,105},Roof={151,91,59},Accent={241,164,70}},
        orc={Name="Orc Welcome",Mode="Quest",Quest="borga_hearth",Style="Canvas",Body={133,80,53},Roof={199,146,64},Accent={82,166,139}},
        mage={Name="Mage Observatory",Mode="Purchase",ProductId=0,Style="Crystal",Body={74,87,122},Roof={86,72,151},Accent={102,214,223}},
        crosshaven={Name="Crosshaven Commons",Mode="Purchase",ProductId=0,Style="Civic",Body={201,190,155},Roof={54,130,136},Accent={188,125,76}},
    },
}
