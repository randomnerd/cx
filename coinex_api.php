<?php
function api_query($http_method, $method, array $req = array()) {
	$key = '098084e65f0d30b9e9bc3051497df04a3264eb53324f71a38d9ecaeaea628407';
	$secret = '0ab134b5e56af279c5c8502578ad4878ef6887543538df7847db8c5ada9e6975';

	$post_data = $http_method == 'POST' ? json_encode($req) : '';
	$sign = hash_hmac('sha512', $post_data, $secret);

	$headers = array(
		'Content-type: application/json',
		'API-Key: '.$key,
		'API-Sign: '.$sign
	);

	static $ch = null;
	if (is_null($ch)) {
		$ch = curl_init();
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
		curl_setopt($ch, CURLOPT_USERAGENT, 'Mozilla/4.0 (compatible; CoinEx API PHP client; '.php_uname('s').'; PHP/'.phpversion().')');
	}
	curl_setopt($ch, CURLOPT_URL, 'http://localhost:3000/api/v2/'.$method);
	if ($http_method == 'POST') curl_setopt($ch, CURLOPT_POSTFIELDS, $post_data);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
	curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, FALSE);

	$res = curl_exec($ch);
	if ($res === false) throw new Exception('Could not get reply: '.curl_error($ch));

	$dec = json_decode($res, true);
	if (!$dec) throw new Exception('Invalid data received, please make sure connection is working and requested API exists');
	return $dec;
}
$req = array();
$order = array();

$order['trade_pair_id'] = 15;
$order['amount'] = 100000000;
$order['rate'] = 500000;
$order['bid'] = false;
$req['order'] = $order;

$result = api_query('POST', 'orders', $req);
#$result = api_query('POST', 'orders/44685/cancel');
#$result = api_query('GET', 'balances');

echo print_r($result), "\n";
?>
