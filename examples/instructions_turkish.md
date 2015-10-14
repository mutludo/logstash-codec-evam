logstash-codec-evam bir logstash plugini.

Bu plugini önce logstash'in içine kurulumunu yapmak gerekiyor. 

Kolaylık olsun diye, isterseniz şu 3 dosyayı logstash'in kurulu olduğu kök dizine kopyalayın:

	evam07.conf
	evam08.conf
	logstash-codec-evam-2.0.1.gem
	json.log
	customers3.csv

Şimdi terminali açın. Logstash'in kurulu olduğu kök dizine girin ve şu komutu çalıştırmalısınız. Ancak öncesinde .gem dosyasının (plugin kodu) bulunduğu path'i not edin ve aşağıdaki komutun içine koyun:

	bin/plugin install logstash-codec-evam-2.0.1.gem

Şimdi logstash'i çalıştıracağız. Ancak önce evam07.conf dosyasını açın ve burada benim hardcode yazdığım log dosyalarının path'lerini değiştirin. Path'leri absolute path olarak yazmanız şart, relative path'ler hata üretiyor. İki tane hard coded path var:

	path => "/Users/mertnuhoglu/projects/study/study/logstash/json.log"
	path => "/Users/mertnuhoglu/projects/study/study/logstash/output_evam07.log"

İlki input alınacak json verilerinin bulunduğu log dosyası, ikincisi evam formatındaki event loglarının yazılacağı log dosyası.

Gerçek koşullarda, bu input ve output yerine logstash'in desteklediği tüm input sourcelar ve output destinationlar yazılabilir.

Bizim durumumuzda, evam sunucusuna tcp üzerinden bağlantı yapılacağından, output'taki file yerine şöyle bir konfigürasyon konulacak:

	tcp {
			host => "localhost"
			port => 6789
	}

Birden çok sayıda output ve input tanımlanabilir. Dolayısıyla, debug etmek için, tcp output konfigürasyonu dışında stdout ve file konfigürasyonlarını da tutabilirsiniz.

Gerçek koşullarda, input yerine json verilerinin çekileceği kaynak neyse onun yazılması lazım. Fakat plugin'in doğru çalışıp çalışmadığını test etmek için, file kaynağı kullanıp test yapabilirsiniz.

Test etmek için şöyle yapabilirsiniz. Mesela, yukarıda ben "json.log" adlı dosyadan verileri çekiyorum. json.log dosyasını açarsanız, birkaç tane örnek görebilirsiniz.

Test ederken önemli bir püf noktası var: logstash çalışmaya başladığında, mevcut json.log dosyasındaki verileri çekmiyor. Ancak json.log dosyasında bir değişiklik yapıp, dosyayı kaydettiğinizde, logstash otomatik olarak tüm dosyayı okuyor ve işlemeye başlıyor.

## file plugin sorunu

evam07.conf ve evam08.conf dosyalarındaki output file ifadelerinde evam codec'ini kullanmadım. Çünkü logstash'in output file plugin'i her nedense, verilen codec'in encode fonksiyonunu çağırmıyor. Bu yüzden, istediğimiz çıktıyı üretmiyor. Bu zannediyorum, logstash tarafıyla ilgili bir sorun. Normalde dokümantasyonda çağrılır yazıyor; fakat kodun içine baktım. Çağırmıyor. Eğer bu önemli bir sorunsa, ben buna uygun bir file output plugin'i yazabilirim.

## json dışında input verileri

evam07.conf'ta input verisi olarak sizin gönderdiğiniz csv dosyasının biraz sadeleştirilmiş hali olan "customer3.csv" dosyası kullanılıyor. 

Bu durumda, evam codec'inin actor parametresine csv kolon ismini yazmak gerekiyor.

## json dokümanında actor field'ının nested olması durumu

json dokümanında actor field'ı eğer en üst seviyede değil, alt seviyede bir nested field olarak bulunuyorsa, bu durumda tüm field path'ini belirtmek gerekiyor.

evam08.conf dosyasında bunun örneğini görebilirsiniz:

	actor => 'city.actor'

Bu parametre şu json dokümanındaki actor field'ını çeker:

	{ "city" : {"actor" : "0025"}, "foo" : "s32", "bar" : {"baz" : ["a","c"]} }

## json dokümanında array verileri

Array şeklinde tanımlanmış verilerde, sadece son değer dönüyor.

Örneğin:

girdi:

	{ "city" : {"actor" : "0025"}, "foo" : "s32", "bar" : {"baz" : ["a","c"]} }

çıktı:

	a,0025,scenario_type,event_type,city_actor,0025,foo,s32,bar_baz,c~

["a","c"] array'inden son değer alınmış. 

