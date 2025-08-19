local util = frequire("moot.src.lib.util")
local log = frequire("moot.src.lib.log")
local tools = frequire("moot.src.lib.tools")
local statedb = frequire("moot.src.lib.statedb")
local rex = frequire "rex_pcre"

local Rgb = util.Rgb

local colors = {PRIOR_SPECT = {Rgb:new{255,220,0},
                               Rgb:new{255,230,0},
                               Rgb:new{156,204,49},},
                AFTER_SPECT = {Rgb:new{0,255,127},
                               Rgb:new{101,204,172},
                               Rgb:new{71,144,155},},
                BEST_TIME = Rgb:new{0,255,0},
                WAY_AFTER = Rgb:new{0,0,255},
                WAY_BEFORE = Rgb:new{127,0,0},
                OUT_OF_RANGE = Rgb:new{97,97,97},}
local function setdefs(type_, start, end_, prior_pad, after_pad, kills, uuids, names)
    return {typ = type_,
            start = start,
            end_ = end_,
            prior_pad = prior_pad,
            after_pad = after_pad,
			resetkills = kills,
            uuids = uuids,
            names = names,}
end
local spot_defaults = {
    -- type, start, end_, prior_pad, after_pad, kills, uuids, names
    -- main
    shd = setdefs('main', 24, 30, 10, 15, 5,
        {'AMShades'},
        rex.new('troll')),

    bss = setdefs('scry', 40, 45, 10, 10, 1,
        {'BPMedina'},
        rex.new('boss')),

    med = setdefs('main', 24, 25, 10, 10, 10,
        {'BPMedina'},
        rex.new('thug|heavy')),

    smu = setdefs('main', 18, 25, 8, 15, 9,
        {'ebff897af2b8bb6800a9a8636143099d0714be07',
         'c0495c993b8ba463e6b3008a88f962ae28084582',
         '501c0b35601b8649c57bb98b8a1d6c2d1f1cea02',
         '8c022638ba642395094bc4dc7ba0a3aaf64c02c1',
         '898b33dcc8da01ef21b064f66062ea2f89235f5f',
         '0b43758d635f631d46b1a1f041fd651e446856ca',
         '1793722d05f49d48f28ce3a49e8b97d59158b916',
         'e28d07530ae163f93ade722c780ce897a4e93a15',
         'a184520b84e948f89e621ab50a500c47faefa920',
         '8048df6be9b61c0f49e988924185ce937a38814b',
         'f026140904d9f0c910b4975b937b20189f225605',
         '952786ea48134ac3505cbabb6567ef35fad13af8',
         'b9bb8741399c7bdf6836cb06148c2e7c4f033853',
         '0663269ccae61f6b313cb378213c74131b394fbc',
         '03a3ca540e9c7fc9dfa914d213b974a0b207f596',
         '3fedc83188999bd20733ba77f02409aee8011127',
         '033906622a542f9e0550608b86932dff52d7e8c2',
         '6ef15a8643f1515f8a96fb646dd8e2ab80bade15',
         'ddabfb40040805889125b223a2d679e0a9716fd2',
         '468f6243998bda671161e6afe079ff5fac866fc1',
         '16a0b8c39025147f9f87cf860b76380af6c9e1d4',
         '4e6aef2cd732fb35c2c110d768605f4aa56194af',
         'a9734849233e5f97fd676676a9853b22b0cb22e8',
         'd57af869e7ff7abe31ceb1245ccbc6d47df49b7b',
         '372dd28add7bfc7ed26f4da4047a501afcf24696',},
        rex.new('smuggler')),

    -- secondary
    ['1k '] = setdefs('second', 25, 35, 5, 10, 7,
        {'3862c5fd0fe83f4080bdb9b94519bf8da89d5015',
         'bfd9a46f2d92d56901814d00a9c3523053ece606',
         '6c6e41001ecd193e7281839d99b4c281ee0f897f',
         '7af9d2df1b733aa0543e3ced6f869504dcbe93df',
         '6ca76db210c7101f4fd0eeba853f57b212731abf',
         '35696de1c035494099961b4155ddff479340008c',
         '79713b4ca3d99f832f3caf58d90c85c244b260d4',
         '0386e4feb14287613807a3975bcf1af2818c6818',
         '5a471316a9f01861444c6e4d9ec057eeae608657',
         'f86d7ab9c53b5c1c7de3226ed5c3f7d05ea6b7ed',
         '1601ed6d1b3e6bfcaaa5791cce74fe612eaca60d',
         '7eacc75e3e626fe0482a0d07d228aaf1871295d5',
         '6b4d27767423fb0d29c8ef8aa8664980f029942f',
         '76fb400b92d8370e5187aab710362126b4b1eda0',
         '0dfd2154b1a1a5f492e2fd8e12814559f4452de8',
         'c43ca6c7fa542d2c8bd06685578b02d6302c1fb8',
         'bbec1d1d952c6d36559e27d7996affa3c3529af6',
         '87910088fc95e65f43cd95046fc34313cf2922a1',
         'a802341d42ab2f3e8a0551b155ce3d274d804386',
         'a7ff939a3775cb0e9f2c7ec34446a711c21f23b3',
         'dcdcedfd38275915db00f8dea416276829e5ab58',
         'd131fb9a9d2ab605d4a94e8acd07283f0c7043bd',
         '1c059b6d8431ab02cf1d321edc65803926ebedfb',
         'a14dff65c90f5224ea0cdb1bb20483c2220cb733',
         '686842f0e6574e07834fdf9e76c4530cc5aad9ea',
         '5ea43c33c1f2b69076028489dcda7764d29a4de4',
         'a2e58e019e725fbde002dfc1f374dc2e24ab81c8',
         '5934d316fe1683c2f07b68c12a24e38b52cdcfb2',
         'afe7bb3e7a6da51f8853dabe80a616d0cb969ce9',
         '5aa0ad1f8b1da33ec2238b7f7dc0d9626c581a7',
         '5c85e502d046f725eaa9b5b8ce06bc271d8961e2',
         'c333ce23e183164992fb0023dd08eb85fc8f7822',
         'f5dd0ec08b4a36ea9c0c4b6da6ed63efa36dd1ef',
         '885c74a09acf91844e41936ffcf2550f48c34a90',
         '95ede200c782fdb09239a2db85dd9f8775922f86',},
        rex.new('Imperial guard')),

    cgu = setdefs('second', 27, 35, 7, 10, 4,
        {'95c3ee90edf97405fd8217936114203fe208ed6d',
         '285a65d776d3557788fa1c7d3a260b854878b67a',
         'cd459b7506eb7f9b41c741d01b5eef91de0d6b93',
         '76baaedd4b31bb7e666d3fd8c0ed1a72ac2f8a76',
         'c3fb28c20095d4764d828d836d9d3c257b3deb4c',
         'b129e486e76dd0c648adf6b6d310b71dfbcc4bfb',
         'ba78df0579a91e1d01f09179a162532b19c2aa06',
         '78ddf153482b6003e43388618e8f93564f1df1ff',
         '780b00a39490812ccfe170095fb62fa6f906c729',
         'e411366f3ff9c84b9cbb7ad75937b8f8aa562552',
         '99d0b05a2e05e85aaadac3b01103b4d56f16d3ff',
         'acd9f4fa7aecea56479f3229bbbd0713daf6e14b',
         '295051bd82708238e97b0c744e62792ed25b9778',
         'c4a83568847ea647ac1c8c0e9b1902a75ba9fde8',
         'f5390582884cc1def3c60a7250c36f9f6fbc81b6',
         '315be737f8676ba7f88e07f533363220b7b42a7d',
         '54f28609e71c7659798bc53278b24537bf67e345',
         'a410bc0ee4c3f9be0155dbd8c43bb981a7c565fa',
         'b61263a674e487126c3d79bf5002737ae86cffaf',
         'd685c7a36794413cdf548c5ec21aad8088de1179',
         '90b91014b5d945a59187fc4b009216f7ced6196f',
         '05dac6937a0bb029440b25554f189cc4d66ee00f',
         '2184c8419b7945b55d718ba87758cb10eb8287d9',
         '6f668a720914be85b0abb5da849e99749d7d0ea3',},
        rex.new('sentry|guard')),

    bma = setdefs('second', 25, 35, 5, 10, 2,
        {-- north apt
         '1e3ae1ba6943a564aae49d57a42309079406fd07', '528230fc8ceb051de4f9c74050c29026ce0fe055', '0238a6d87503d207d821e18f76f224d0a7659828', '69c367485a2f91b38ab1cfb816ac27cd1bf3c380', '025c8fb7331f0b00769c9d413c399600bc8fde49', '1d39e3a56eb8a09ee8f30c470ce5e45e54fa3c64', '53bb75fa7486f044bd386cd82ac60162d0ac8183', '435bb313d903985d89324cd8cdbba8068487b2a6', '6b55b93d3c02e040b6e9664790ccf0feda00a971', '6c367a8d2c37a2cdd64d9b5c278ff106f418fdca', 'cf98f69e09a9801175ec07e9c369bda97f1eb81a', 'e243e9430cbad4877cd4a4e4c318d9b968abb7bc', 'd58bd56e91f015e41fdde8da5efc7229068f47e6',
         -- northwest apt
         '9f2c3ba13978e38041a7f411503d402b6b4b1ef8', '4377f4ffe153460d7e9ce4766b83911d873b4824', '67a5023068111bb587aa48b66391c5d1bba42f5b', 'b36800b505142c34b6a59e3d353dc23bb6387b75', 'd58ab6e4ed962203abc0427db50ddc81949bb88c', '84e8e1d41101c9240faef458c85fb625526020d4', 'd5d67fc2e1e936a040cffb600bb9972add4e52a5', '7acb877a5e00d27b548a19f0a90fea5b26a5140f', '8654296946a63ab5dfe63e1e156af6ce4c191fd4', 'fa1996cf8b703515fae6660b9f493b9a93c80ee1', 'e6439398b3a453a723adc85bd5c68e8f806fdf49', '14fbf68aa9eed36cfe4805c65b75915304b39f8f',
         -- tea clipper
         'c6b9247373df384e09820448fbb30fc0b03406a3', '2d13f3b060588de14211a94139f5301f3c274d1a', '69c03124007c140469f3fc26753ccc23bc740c44',
         -- market
         '730753618119e17ed7fbe7a5303f65e774657a76', 'f6c60dd36ed38707eb954c3a670f2f9370a79399', '4fc09542c1022fbe2b338f4cd61e8e5c1c4fb059', 'e4646eab906aef1187a9dd3e980441b8f6b8d68c', '0ae9d8c4f2b48f4fcc4cb57fd85443399be2ecc5', 'c7c6f5720d2c587f80696b6f0ec7f9ac0f084b06', 'd62816ce9950dffe6bafca3f40d40d61433cc97e', 'bf170d49dd81b1e0f3c44c085b5bd390a08172f3', '41278c32e9de6c04e7a65b510689ce4d95387a24', 'b057e66c03d0deaa77992ad1e6a178a586a8953d', '9588161445f5a90547bde8158c0e4ba02ba132c8', 'caa9cb5be05e011bb3765425e496af5ba177e3d0', 'dc95424a18d18ecca90d95bfa1cc8217b1ddfa83', '9374012a1e06e9cdb09819550abdbc13e8010995', '639c815db46cbcf8d443bdb783dd10f33fad8f49', 'b5a9944c6e264eb959d36ed02f6907322f6399c8', 'e3aa6ddd99d95e39b93795bfbde3e66b73a0d02a', 'e9f65119ec8acc822a8efb47d4146ee7fa924b4a', '31d5891d6494cca3befb355bc63be0810ce50d40', '982e809a23be69f5bcb0aba65e9f0b31da73e806', '263ea81beb12329ee2ff24f65e9ba95cc94a95c6', '003f72baae4e13372e6217e2b32891a743ba750e', '4dcb6bf88f306c2dc0c1e22677373d04552bab7a', '73ee4137af30a761ea3456d88d30741edcdc507f', 'f1d87d47acb65d172469afb0d3ce806653501ac6', 'fd6ad333b5c9261e58782724fa21ab3b7f4c3f9c', 'bc627ccfb2408f6e0bc2a0b1d3a159d92d05ce58', 'e4cdd8e544188af7bcf02d6aa97a8b1be536b307', '1cda9f3901bcaf3d104ddfade765a9aef69a2d60',
         -- stalls
         '98857585e5b0c25aad787f4a814e72b9a07008a9', '2ad3b14d9c39254b67ec6cb0003131eac4cccf3e', '9bfac54bbc89da35556960180a410e060a479ed2', 'a1e69a1a20c87d5e1640b79c1d026a6b75404f6b',
         -- east apt
         'dae754ba34a7b166ff823de8262b390293edd79a', '5b32c224783d165a12609971712a2318450ba3a9', '3b6f4b9504332ee1ccdf3ff1d01eb43aac3e1148', '633e4a166d6c3ec2bddb49f7a715b6b295bd2e18', '87d410ca8290b97848c27d6d50d69547a044813f', 'c35aabd302e8bb46d6a9d6f7fbb5068022e097f9', '77ce87035bef86def761b72a11ababa9c48f314c', '94f4b3902fe0f4bdfc42e7018a71d7134482dbbe', 'c66fc58c1c269a5c8d8de6793dd9b15095b14787', '840f44965836a66cfac9932e1a582cc6fb925170', '9e822bf44096bc8f2db57fc0cba5f73ea2ecb0a5', 'c0829789c60e8bfcbb6ab6ecb667a59c8decefee',},
        rex.new('captain')),

    djb = setdefs('second', 35, 45, 5, 10, 10, 
        {-- row 1
         '9bbdc927fc1a5b3d649aeaf9cd5ceadc4ec992a9', '388850f565d215855886d8cbefce7911d1b21313', '68dd7dfb1457ed867dc74b033223478b2a70ab60', '4ed9b9006731e04ade1ed9c34d41861fbe8ae1b1', 'f6ef1862afac1cc327688133471e8c61aa1a9627', 'e11dd47549db96d9c7422722faeba47ebba35d05', '3b2ef2ce3cf7f13190ab30c7e90ad9a8e0f23bf6',
         -- row 2
         'a16c7982aff3038f00e35c7c14bf4dddc3f363d3', 'dc901483b6eb1af50d1fcd831f3c38a6773c0532', '88578bc2bb0e627df0f0f2903c4c373b33f810da', 'ee0ea007e6dbd740482acf81383b1c188f97bd23', '8c4e4c2eaf7cb4db280f253660a188d7fc2ae741', '8d82cab11a6a5063c00c09502e290fd5121bef2e', 'cd288cae38a7bad77691cd26763d687e10bb4937',
         -- row 3
         '0c4f6806e06b7b32d4682b623c6beb88c5a46a85', 'e06583ec49edb5350abc913725fa32d1ffbb6175', '682d2bfaffc2bb53a2dec39765b3e6e46165f7b7', 'c83c7fe6a50cd9c33c33460e817fde745ac24f27', 'ef2718a5508fa10fd9555390534b921656fb8f0b', 'b455aa46e25a5de6fbe72daf2e4d5c4344d3283b', '267a1e0b26795f7a67211c71c9b265c35f306aae',
         -- row 4
         'c5ad85e00c2fb42578125e33069ec78959d86351', '69f338bf5500c06b1e3e412759fb85a4d65d73f8', 'af6f704d5784518aada0f19593b2e9d38411abed', '54433577da7798897090d452bbdfba42eee2ee2f', '6366c69a856329153d12b2995d27a363e67e9d03', 'ae0ccb4a93f9773de9821384e74b1804fa7de532', '44408d86685482c895bd5fb5c064208d9b004965',
         -- row 5
         '66378c0e7cee66cd1c1e660b66fd56442fa5dfbc', 'dc7a07f401993816d5a4fe315206ded25857154f', '789868105135440c6e4d34047be4381d97cfd610', '8c8f53eb3b312ac3746341a6700703a98234ce69', '8791398637af192887697dc2fda1a39f1f12394e', '21b4fa7b0107f023f3da13803b6b6f269f0271da', '1fb8ec5a1f1c29d2aef81fd20d88bae58e0064e9',
         -- surrounding southeast
         'b210eb9f0242cc265546d7898ac60e0f12817277', '887c346221fdd3da3415a3e7e2ba5ddfd802c283', 'a98ba23f065024730348ae8f6a6a0279989b662c',
         -- surrounding northeast
         '7a2aa4bee2034787e343ff3e1e8962b83f103f0d', 'bab8a8a3a5d2e10b1ad71d547652146bc5c21979', '0f586a3f7dba7fdabaa17bcf86b041b96863b1db',
         -- surrounding north
         '09938350fcf5bf00f1a8c708335257ad9c2db59d', 'ee03d1b1e80aff1bd3c3f047026846108ef81aba', '29349e29662e8b1cf15b0d1df2df167458901b7e',
         -- surrounding northwest
         '3f545320010e36a11d9a319115d6079af50e279a', 'b416e96838a5b9ff6ce18c82c4d0d288caf262e5', 'dc5d4085c37b0d2c8f54a4b12413976e5860a2f6',
         -- surrounding southwest
         '1eb369ef019629c0fe956f0a9ff03519b8a3fe3c', '37a1eb4ecf0849b3f7c156df2821cc54d6eccee6', '71c2dc4077de5784c920440700695c9a3f1e5274',
         -- surrounding south
         '180aa253c572582e880ad9735eaff3b652223510', 'f2294a501564838b51a7234a5f25c4194c3b3f37', '91e6dc07e770dbcf3eb3c526977666f02938b42a', '3af1cb0816245409b73c733eb503dc7c7110ded6', 'a153af6c0a94ccef7f2cfe82e6962e4690ff944b',},
        rex.new('guard|soldier|mercenary|giggly|warrior|spy')),

    -- hot
    gnt = setdefs('hot', 50, 60, 8, 10, 3,
        {'2accfe93cf2daddad4b4c5dde8d2c09951938d5e', 'a3c7efad1e05b64f673ac0ea996cd383157241bf', '8cb5e2c6c0ac116cfe69cfefa73a035ad9ea9ec7',},
        rex.new('giant')),

    grf = setdefs('hot', 37, 45, 16, 8, 8,
        {-- upper inner
         'aa5d3cfcb0ad8df1e4737d8c5e2d8151cf8acb86', 'de4e8ed869fd0d6a6795fe5ed504e3c3400946eb', '5406e564343fda9a97d5f27255baa04e2ab44a5f', 'fcc311043aeff5941e612d01f9141ca53a70fc32', '9c6da28cd342030de373338ea92bc74af9624166', '8d79b3a75d076e7dea0def6c32cc7c70e5cbc436',
         -- lower inner
         '72019ab24d167fe86b553234428d611d440241b5', 'a1511e4ca8a70d93d551347494fc97ce2da41c62', 'd73c3f706c6f1839c94af1a2271d4faa5b7318be', 'f7a0c67b412ef21acb6e4647df124b1576043d3c', 'e2817d1202329e6b28a62e186e95e53f07657c5e', '890966c6b2b690fc1b04749a7bf9d04eca29dcec', 'f5cb49ea1b91109f23a450e5ee3fcea0fa1cc35d', 'a914b6c578b073a83ab576d2a94d2189cbfedb6f', '24ed39fb0af9cd0da4b980dc2a56de999f45fae6',},
        rex.new('grflx')),

    sna = setdefs('hot', 50, 60, 8, 10, 5,
        {'02954ba794941375e7c821956ed2762da2feb237',
         'f255c95722d890b854ea47aad70a204a252b9b41',
         'f0ecc2b0e5969fb542b08ca4d2821181c847f3c2',
         '501805b9c6a691d5cf69f3066e2a2ff33f5eaea8',
         'febf20a0847c00f9d7f1fd12834517bb22dcbf4a',
         '475911910fd731946bf67af4d379835188444b3c',
         'a485bb55fa9e9c90843258c915f1a803fc4be596',
         'ab852c2eeadc1ff623d01d17a4fd453f6bf1e95a',
         '5d2da42534fa5d8d65c69f9b0aaac06fe2bcc063',
         'b5cb9ef87ad9051b423c17438e6a848f7fc492e8',
         '184cae38cfb5584827d33a2e9ee053f0789987f2',
         'd3a5296feb2e3496f44d93dd173ad9ec440938a0',
         '8029e603ff702c0ee25ef5ffda57656318253a18',
         'ee2c6b203b554fbed02c4361c313064de5dd1e2c',
         '116f211f7b0ca4232f14de165a5cbd63c8fbfe40',
         '7e04aae777f2b0c2800fe0d9c56fda567e434559',
         'b07fe2158e9ff237bb1f0879356a73a3e9770927',},
        rex.new('rujona|outlaw')),
    -- fakescry

    rat = setdefs('scry', 25, 42, 5, 10, 1,
        {'03360211b315daf089d9ba329dd32417b9c7f54c'},
        rex.new('Hlakket')),

    cas = setdefs('scry', 37, 45, 5, 10, 2,
        {'11f3c9c2ccc3c66cdcaaad2a44854531275ccc52',
         'd84d44aaa9bd513fe0508b26deb5df4a00c53f0a',
         '6c5e875f8b49220f2fe71fd59871ac418c7169aa',
         'e9a4b7457be59438fbbfc44559e70a97c106f62c',
         '8b7eefa4c958d0ff05029fe390d772ad42b3c1c4',
         '081bb9e8862a6ac8e483643a54676ce2e85125b2',
         '8357512e66bfacc2447da77a7274f006b1118853',
         '2728c33f0ce86c4c14bdb25962a8a9ab2d500d61',},
        rex.new('Gumboni|Harvard|Ciaco|Marchella')),

    sta = setdefs('scry', 37, 45, 5, 10, 2,
        {'aeb7458ea6687042e3583984fba9669928159b91',
         '6919307c65d0bdb432a2f02689447006decefcf8',
         '0718929d8b608454f33d0bcb66b48d22caf4be8c',
         '62603b86954ab72c73d48dc95fb74d71cbdc7608',
         '70bf1dd2c838b6b018f76886832c161c66495813',
         '77e943d49de7348fdef7c49bfcc05427af22d739',
         '09451b54e0d98a60c52ab9fdccdb7370c383c0b1',
         '42d54db8308754b3c65390ed5471417ec77f04db',
         '8ce99945e33380d22cb63199afe67d7fdfce40f1',
         '745f5594d43e94c782141c67b73fe02365d2eca4',},
        rex.new('Corrola|Accardo|Enrico|Casso')),

    -- wamg
    sha = setdefs('wamg', 27, 35, 7, 10, 1,
        {'15089447ab5046dd611b3416095d7e04f7845524',
         'cb8aaf1cc79bb5e8977a6d0124791dd116eef443',},
        rex.new('lion')),

    pit = setdefs('wamg', 50, 60, 5, 10, 1,
        {'70546ec71867645ab5c51e9ce6087b75dcf4176f',},
        rex.new('crocodile')),

    doj = setdefs('wamg', 25, 35, 5, 10, 4,
        {'08552763702451e904ae42433f2e600a2d071c3e', -- center n
         '46be4e1a8acee71dd1a219f922f0336959aa2bc8', -- east n
         'adef8379d080af980955bc50fc9c7ec8647ade18', -- east s
         'f80561834fb101d794b574ef5009e689f55f9f45', -- south s,
         '6139cc42dc377c1bda38128091c7a1cbfd3d2746', -- west s,
         'b25bbca7ab1a3e9757c3af0816d67253f48ab2d9', -- north n,
         '62c1d0d4a3449a4db14dc64554fecb13f663ad03', --[[ s s s ]] },
        rex.new('student')),

    coc = setdefs('wamg', 25, 40, 5, 10, 1,
        {'d69bb17a72082dd91741f5a77acf9e94f7523897'},
        rex.new('vicious spider')),

    cab = setdefs('wamg', 28, 35, 8, 10, 1,
        {'cca9645565f2bb0d017ea9b1dcc9d1b3e9fcfe72',},
        rex.new('drunkard')),

    -- eph
    hrs = setdefs('eph', 24, 30, 10, 15, 4,
        {'f4949e23d9ae05eb9b104ea3aa99630e2dc095be', -- cit ne
         '4064c938b803bb0993333733ceb240c0fc4116e1', -- cit e
         '4da8fd81aa0b5a2f2ee06cc4ca52ed5c618a95cd', --[[ horse ]] },
        rex.new('guard')),

    esm = setdefs('eph', 24, 30, 10, 15, 10,
        {'19090c8d23775e5141ef7a6993831e0abafa060b', -- port spot,
         '4ef34088865bf77ee041effc943e712841ef6545',
         '9f3470d4be6f5a1f3f4812f0dc7268fe69cb8955',
         'f82ebe3b636d845994b657fc889e904492299b16',
         'd833ef4ab07ec180535e3558a0373483329d4c9b',
         '68ff9ded222b7618451fc97de6a4054948a7967d',
         'fbc38e2b7f9cda748cba813bf34df70cc370e18b',
         '81373d0fc7c541cfb0d9f9b06787c6a0ddf93baa',
         '19acf4962ea15d6a5b171b0c0231122058fd863b',
         '53a5904d59bba5a0e8a560f2bff2e63a04ee627c',
         '28188e634321d20c69d5d60196de406d9a09a485',
         '3ca68530454c4184b8a84ce32e614ca8656b871c',
         'a6c22fa5e9ac55abcc5ce20afc31ec80944f18d6',
         'ae4ac8eb9650667ac17ae813be9be64ab645ce11',
         '9a57632dbd4512965cbcf5882a761dc09953b0bd',
         '2693840ef9cb47d9efe401656eba2525a233b63a',
         'f75dc94eb17a1ef0b5c349fbcce1420ef60bfabd',
         '929c4cd80edfb0002ac47acb15cf22ce28c74a5e',
         '32226a1fa4f3a7534e4db7f02d0b1d5a88c555d9',
         '3c93b3b4d4d1e2fac332cfc1bf8eecc357ad369e',
         'de91f2422a096a4e3fcc37b89e0a4052c817a90f',
         '57c05b0b807fa921e0acfb26493fa4996a043d36',
         'a911a7d8f3855723466628d410c02452be50b7a8',
         '7899518740db02fbeba283e7f51c2149d1c71a03',
         '19ad4a8929217b20a045c22dda17a865f97e2215',
         '2119d5bb24a0c354e40cd3503291dcf7ae54671d',
         '3776434aead03b571de3dc5e44e898cba51a7add',
         '8d6c157d6bee2c0fd3933f0b73f3f54a4a9552d8',
         '4a0a158404ae65f64190cf8a8393bad69edf0d6d',
         '88f0ebcc97d6b2d72c1699e3052758f9c65bd50e',
         'af23adbd14d68ceaa9b781f4d8fab955fbd4af3c',
         '3a9d20376a4b7a087f54e13068383b4df5544311',
         '67d96ca6f671ebee877910ee2b59517e250f9478',
         '7ebc925a02da1e15abb34ec1c1ca1cc168af70ed',
         '65f1364b724226dfa1d003f9d39f2480fa6f05ec',
         'f4f3433a0ef37e385d0fabc78e64609466dc576f',
         '6fbb8964d22fcdabc89085881256ab49f409fb86',
         'd56a0d1905583a84d4dd60a65fc7b4379732bde4',
         '532108fada1f630822e2b5493d849ea190abb296',},
        rex.new('.')),

    ene = setdefs('eph', 24, 30, 10, 15, 3,
        {'b8befebdd59bf2fd66fdb56f928e1a18855a01c9',
         'fcb0fe4caf4e402cc8d91bbd668e18d7d67782b2',
         'fd0a9fbce827dd36a6127f2f59d93b9fdfab511d',
         'f8c15ab6be0a6dcc41cf97cfdcd225dc49978d7a',
         'c38d6889d9787c159a31530a1298c621efe6ad71',
         'ea8d5673e6cf0e785c812e48b026fd9c0b1d0168',
         'ff35f8770e268b75ae7eab13e5ed94ed0685a256',
         'c7279413713815a41431201072f5e49928f67bf4',
         '4f5a732ca8b3b5573675b72e6ff925261007c6ff',
         'd84d902cb6b6d59b5373e3a8229236915d284504',
         'a2da6f53b5c128c30d5ecaef80ed057cc021063e',
         'dbd1394b871b35c914973440b552f43257d4a420',
         'cbe4fd31f21a6017f2472fb4e738f4de08ce7653',
         '8915341e82d8820c5523cb6ff5a413d5fbacfc08',
         '48d7d4649c1de8e64dfd25aa408123dbebbb85cb',
         '36f143a237a1167df324679bf3fda29da0b4c0ef',
         '6ce9158a6e3a97d95a3d8c89adb6bd12a1cf7775',
         '07a96858d47699492bcc5bfd06327ab38b581f4d',
         '857cd0d88499ee98446135a0cb1cc2a17764fb80',
         '7c7fcccd51039b0fad9db03db5b280739c0582ed',
         '2379000fc8201ae4dba99781e1f3bc948481d2f4',},
        rex.new('hoplite')),
    -- cwc
    -- misc
    wgn = setdefs('misc', 25, 35, 5, 10, 2,
        {'efdf7cb8dfcf0f78c10488471899b4e15ae45e6d', '6defa37c6e05a11807104e98f17e3f5b48ab58ca',},
        rex.new('guard')),

    doc = setdefs('misc', 25, 35, 5, 10, 2,
        {'f8f9e4072a9506d20f0b97ba693eff18d7473ca9',},
        rex.new('guard')),

    ban = setdefs('misc', 25, 35, 5, 10, 12,
        {'282706c9265237bea57b69a1a0238c006b896e6b', -- south
         'b4de7021aa34ef6649cacabd5cbc77bbd729c706', -- south sentry
         '30fd0d4f81959a51566d0ce0c0e735d97ffb0273', -- sw tent
         'a3a37a9ef53ead2bd0626b4ed738c816b8ef1cb8', -- nw tent
         '2434d6b0aa9bc8a75b6b4c795266454cf5e13dbf', -- leader sentry
         'e2b0b57859b128a301bfa57a39c257bb0ad89c6e', -- leader room
         'd8ee8fbe5d5ccbfba08e92ecf6670371f57e1341', -- ne tent
         'c5284592b270396c59b179fe3ce8140f87053ee7', --[[ se tent ]] },
        rex.new('bandit')),

    oas = setdefs('misc', 38, 45, 13, 15, 10,
        {},
        rex.new('patroller|captain|mystic|hermit|commander')),

    piz = setdefs('misc', 37, 45, 4, 10, 2,
        {'9d801d155ff155b7134ebf5eeb8c73117563da56', '82129d6537efab6e0ff30cdb97b2729d23642b3f', 'babb4de327cd0e604e5368a82219b00772195e68', 'ae9c75c25087146424d62b4e7a497fe3e8a70be2', '41a9038660df9a36f11513d865212f6a1d176853', 'c28bf5e86ee23fbb8fb8d58fbb4df6a16c8f5645',},
        rex.new('Clemence|Debois|Cicone')),

}

local Spot = {}
local unset_sentinel = -1
local spotsheet = statedb.db.spots
function Spot:new(name)
    local o = {nil,nil,nil}
    for k, v in pairs(spot_defaults[name]) do
        o[k] = v
    end
    o.name = name
	o.row = db:fetch(spotsheet, db:eq(spotsheet.name, name))[1]
	if not o.row then
        db:add(spotsheet, {name=name,
                           last_visited=unset_sentinel,
                           last_killed=unset_sentinel})
        o.row = db:fetch(spotsheet, db:eq(spotsheet.name, name))
    end
    o.last_added_kill = unset_sentinel
    o.kills = 0

    --o.row.last_visited = os.time() - math.random(30, 150) * 60
    --o.row.last_killed = os.time() - math.random(30, 150) * 60

    self.__index = self
    setmetatable(o, self)
    return o
end
function Spot:set_visited()
    self.row.last_visited = os.time()
	db:update(spotsheet, self.row)
end
local kill_window = 6 * 60 -- seconds
function Spot:add_kill(name)
    log.debug("kill '" .. name .. "', kills: " .. self.kills)
    if not self.names:find(name) then
        return
    end
    local diff = os.time() - self.last_added_kill
    if diff > kill_window then
        self.kills = 0
    end
    self.kills = self.kills + 1
    self.last_added_kill = os.time()
	if self.kills > self.resetkills then
	    self:reset()
	end
end
function Spot:reset()
	self.row.last_killed = os.time()
	self.row.last_visited = os.time()
	db:update(spotsheet, self.row)
end
function Spot:get_dstring(pad)
    local padding = string.rep(' ', pad - (#self.name + 4))
    local bg = Rgb:new{0,0,0}
    local name_fg, time_fg
    name_fg = self:get_color(self.row.last_killed)
    time_fg = self:get_color(self.row.last_visited)
    local name_s = util.Dstr:new(self.name, name_fg, bg)
    local lv = self.row.last_visited
    if lv == unset_sentinel then
        lv = '  '
    else
        lv = math.floor((os.time() - lv) / 60)
        if lv < 10 then
            lv = lv .. ' '
        elseif lv > 99 then
            lv = '  '
        end
    end
    local time_s = util.Dstr:new(lv, time_fg, bg)
    return string.format("%s: %s%s",
                name_s:tostring(), time_s:tostring(), padding)
end
function Spot:get_color(t)
    local ago = (os.time() - t) / 60
    if ago >= self.start and ago <= self.end_ then
        return colors.BEST_TIME
    elseif ago > self.end_ and ago <= self.end_ + self.after_pad then
        local el = ago - (self.end_ + self.after_pad)
        local perc_pad = el / self.after_pad
        if perc_pad < 0.33 then
            return colors.AFTER_SPECT[1]
        elseif perc_pad < 0.66 then
            return colors.AFTER_SPECT[2]
        else
            return colors.AFTER_SPECT[3]
        end
    elseif ago < self.start and ago >= self.start - self.prior_pad then
        local el = ago - (self.start - self.prior_pad)
        local perc_pad = el / self.prior_pad
        if perc_pad < 0.33 then
            return colors.PRIOR_SPECT[1]
        elseif perc_pad < 0.66 then
            return colors.PRIOR_SPECT[2]
        else
            return colors.PRIOR_SPECT[3]
        end
    elseif ago < self.start - self.prior_pad then
        return colors.WAY_BEFORE
    --elseif ago > self.start * 3 then
        --return colors.OUT_OF_RANGE
    elseif ago > self.end_ + self.after_pad then
        return colors.WAY_AFTER
    end
    return colors.OUT_OF_RANGE
end

local Spots = {
    column_width = 12,
    configs = {
        def = {rows=nil, cols=nil, prior='all', expand_horiz=false},
    },
    priors = {
        all = {'main', 'second', 'hot', 'scry', 'wamg', 'eph', 'misc'},
        rhath1 = {'wamg', 'scry', 'hot'},
        rhath2 = {'eph', 'second', 'main'},
    },
}
function Spots:new()
    local o = {lookup = {},
               all_rooms = {},
               main = {},
               second = {},
               hot = {},
               scry = {},
               wamg = {},
               eph = {},
               misc = {},}
    for name, defs in pairs(spot_defaults) do
        local s = Spot:new(name)
        o.lookup[name] = s
        o[s.typ][name] = s
        if not o[s.typ].length then
            o[s.typ].length = 1
        else
            o[s.typ].length = o[s.typ].length + 1
        end
        for i=1, #defs.uuids do
            local uuid = defs.uuids[i]
            o.all_rooms[uuid] = s
        end
    end
    self.__index = self
    setmetatable(o, self)
    return o
end
function Spots:get_max_rows(prior, expand_horiz)
    if expand_horiz then
        return self:get_max_cols(prior, false)
    else
        local max = 0
        local p = self.priors[prior]
        for i=1, #p do
            local cat = p[i]
            local o = self[cat]
            if o.length > max then
                max = o.length
            end
        end
        return max
    end
end
function Spots:get_max_cols(prior, expand_horiz)
    if expand_horiz then
        return self:get_max_rows(prior, false)
    else
        return #Spots.priors[prior]
    end
end
function Spots:get_all_sorted(cats)
    local sorted = {}
    for i=1, #cats do
        local cat = cats[i]
        sorted[cat] = self:sort_cat(cat)
    end
    return sorted
end
function Spots:sort_cat(cat)
    local weights = {}
    local cat_spots = self[cat]
    local now = os.time()
    for name, spot in pairs(cat_spots) do
        if name ~= 'length' then
            local k_elapse = now - spot.row.last_killed
            local w = 0
            if k_elapse > spot.start * 60 then
                if k_elapse > spot.end_ * 60 then
                    w = 1
                end
            else
                w = spot.start * 60 - k_elapse
            end
            weights[name] = w
        end
    end

    local sorted = {}
    for name, weight in pairs(weights) do
        if #sorted == 0 then
            sorted[#sorted+1] = {name, weight}
        else
            local inserted = false
            for i=1, #sorted do
                local this = sorted[i]
                if this[2] > weight then
                    table.insert(sorted, i, {name, weight})
                    inserted = true
                    break
                end
            end
            if not inserted then
                sorted[#sorted+1] = {name, weight}
            end
        end
    end

    -- translate to actual spot objects
    local sorted_spots = {}
    for i=1, #sorted do
        sorted_spots[i] = self.lookup[sorted[i][1]]
    end
    return sorted_spots
end
function Spots.get_line_horiz(sorted_cat, cols)
    local line = {nil, nil, nil}
    local min = math.min(#sorted_cat, cols)
    for i=1, min do
        local spot = sorted_cat[i]
        line[#line+1] = spot:get_dstring(Spots.column_width)
    end
    return table.concat(line, ' ')
end
function Spots.get_line_vert(sorted, prior, cols, i)
    local line = {nil, nil, nil}
    local min = math.min(#prior, cols)
    for k=1, min do
        local cat = prior[k]
        local spot = sorted[cat][i]
        if not spot then
            line[#line+1] = util.pad_string('', Spots.column_width)
        else
            line[#line+1] = spot:get_dstring(Spots.column_width)
        end
    end
    return table.concat(line, ' ')
end
function Spots.get_header(prior, cols)
    local line = {nil, nil, nil}
    local min = math.min(#prior, cols)
    for i=1, min do
        line[#line+1] = util.pad_string(prior[i], Spots.column_width)
    end
    return table.concat(line, ' ')
end
function Spots:get_lines(rows, cols, prior, expand_horiz)
    local lines = {}

    local prior = Spots.priors[prior]
    local sorted = self:get_all_sorted(prior)
    if expand_horiz then
        for i=1, #prior do
            local cat = prior[i] .. ':'
            local s = Spots.get_line_horiz(sorted[prior[i]], cols)
            local l = string.format("%s%s",
                        util.pad_string(cat, Spots.column_width), s)
            lines[#lines+1] = l
        end
    else -- expand vertical
        local l = Spots.get_header(prior, cols)
        lines[#lines+1] = l
        for i=1, rows do
            l = Spots.get_line_vert(sorted, prior, cols, i)
            lines[#lines+1] = l
        end
    end

    return lines
end
function Spots:on_kill(name)
    local room_id = gmcp.room.info.identifier
    local spot = self.all_rooms[room_id]
    if not spot then
        log.debug('no spot for current room, returning..')
        return
    end
    spot:add_kill(name)
end
function Spots:on_roomid(uuid)
    local spot = self.all_rooms[uuid]
    if not spot then
        return
    end
    spot:set_visited()
end
function Spots:show(config)
    if not config then
        config = Spots.configs.def
    end
    local rows = config.rows
    local cols = config.cols
    if not rows then
        rows = self:get_max_rows(config.prior, config.expand_horiz)
    end
    if not cols then
        cols = self:get_max_cols(config.prior, config.expand_horiz)
    end

    local lines = self:get_lines(rows, cols, config.prior, config.expand_horiz)
    for i=1, #lines do
        if config.window_name and #config.window_name > 0 then
            decho(config.window_name, lines[i])
            decho(config.window_name, "\n")
        else
            decho(lines[i])
            print()
        end
    end
end

spots = spots or Spots:new()

local group = "spots"

-- SCRIPTS
function spots.set_visited_callback()
    log.debug("set_visited_callback, gmcp.room.info.identifier: " .. gmcp.room.info.identifier)
    spots:on_roomid(gmcp.room.info.identifier)
end

-- EVENTS
registerAnonymousEventHandler("gmcp.room.info", "spots.set_visited_callback")

-- ALIASES
local n_cli = "cli"

tools.add_alias(group, n_cli, "^spots(?: (\\w+)(?: (\\w+))?)?$", {args = {"matches"}})

spots[n_cli] = function(matches)
    matches = matches or {}

    local command = matches[2]
    if command == 'help' then
        print("spots help:")
        print("\tspots\tshow all spots")
    elseif command == "reset" then
        spots.lookup[matches[3]]:reset()
    else
        spots:show()
    end
end

-- TRIGGERS
local n_do_on_kill = "do_on_kill"

tools.add_regex_trigger(group, n_do_on_kill,
    [[(?:^You kill (.*)\.$|deals the death blow to (.*)\.$)]],
    {args = {"matches"}})

spots[n_do_on_kill] = function(matches)
    local name = matches[2]
    if name == "" then
        name = matches[3]
    end
    if not name or name == "" then
        log.error("No match group passed for on kill")
    end
    spots:on_kill(name)
end

return spots