PRP.Banking = PRP.Banking or {}

function PRP.Banking.HasAccount( cCharacter )
    return cCharacter:GetData( "banking_inventory_id", false )
end