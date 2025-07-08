up:
	docker-compose -f db/docker-compose.yml up -d

down:
	docker-compose -f db/docker-compose.yml down

logs:
	docker-compose -f db/docker-compose.yml logs --tail=100

ps:
	docker-compose -f db/docker-compose.yml ps

restart:
	docker-compose -f db/docker-compose.yml restart 