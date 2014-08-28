module SubHask.Category.Trans.Constrained
    ( ConstrainedT
    , constrain
    , proveConstrained

    -- ** Common type synonyms
    , EqHask
    , OrdHask
    )
    where

import GHC.Prim
import qualified Prelude as P

import SubHask.Category

-------------------------------------------------------------------------------

type EqHask  = ConstrainedT '[P.Eq ] Hask
type OrdHask = ConstrainedT '[P.Ord] Hask

---------

newtype ConstrainedT (xs :: [* -> Constraint]) cat (a :: *) (b :: *) = ConstrainedT (cat a b)

type family AppConstraints (f :: [* -> Constraint]) (a :: *) :: Constraint
type instance AppConstraints '[] a = ()
type instance AppConstraints (x ': xs) a = (x a, AppConstraints xs a)

instance Category cat => Category (ConstrainedT xs cat) where
    
    type ValidCategory (ConstrainedT xs cat) (a :: *) (b :: *) = 
        ( AppConstraints xs a
        , AppConstraints xs b
        , ValidCategory cat a b
        )

    id :: ValidCategory (ConstrainedT xs cat) a a => ConstrainedT xs cat a a
    id = ConstrainedT id

    (ConstrainedT f).(ConstrainedT g) = ConstrainedT (f.g)

instance SubCategory cat subcat => SubCategory cat (ConstrainedT xs subcat) where
    embed (ConstrainedT f) = embed f

constrain ::
    ( ValidCategory (ConstrainedT xs cat) a b
    ) => cat a b -> ConstrainedT xs cat a b
constrain = ConstrainedT

proveConstrained :: 
    ( ValidCategory (ConstrainedT xs cat) a b
    ) => proxy xs -> cat a b -> ConstrainedT xs cat a b
proveConstrained _ f = ConstrainedT f
