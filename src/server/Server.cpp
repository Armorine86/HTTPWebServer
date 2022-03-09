#include "Server.hpp"
#include "Response.hpp"

Server::Server(server_info serv_info)
{
	Sockets socket(serv_info);
	run(socket);
}

// Creates a new Pollfd, adds the new Client fd
// and sets events to POLLIN
pollfd Server::addToPollfd(int newfd) {
	pollfd new_pfd;

	new_pfd.fd = newfd;
	new_pfd.events = POLLIN;

	return new_pfd;
}

// Handle Events sent to the server socket. Accepts a connection
// and receives a client FD. The FD is then pushed_back to the 
// Pollfd struct vector.
void Server::handleEvents(PollIterator& it)
{
	socklen_t addrlen = sizeof(client_addr);

	if ((client_fd = accept(pfds[0].fd, (struct sockaddr*)&client_addr, &addrlen)) == -1)
		perror("accept");
	else {
		pfds.push_back(addToPollfd(client_fd));
		it = pfds.begin();
	}
}

// Handles Client requests. If the FD in the pollfd vector is
// the sender FD (client), we can send the response to the same FD
void Server::handleClient(PollIterator& it)
{
	int bytes = recv((*it).fd, buffer, sizeof(buffer), 0);
	// TODO if buf is bigger than max_body_size : error 416 Request Entity Too Large

	std::string str_buffer = buffer;

	if (DEBUG)
		std::cout << TEAL << str_buffer << END << std::endl;

	int sender_fd = (*it).fd;

	if (bytes <= 0)
	{
		if (bytes == 0)
			std::cout << "pollserver: socket " << sender_fd << " hung up" << std::endl; 
		else 
			perror("recv");
		close((*it).fd); // Client request resolved
		pfds.erase(it);
		it = pfds.begin();
	}
	else if ((*it).fd == sender_fd)
		sendResponse(str_buffer, sender_fd);
}

// Parse the request sent by the client and builds a response.
// Memcpy the Header and the Body into a buffer to use with send().
void Server::sendResponse(std::string str_buffer, int sender_fd)
{
	RequestParser request(str_buffer);
	Response response(request);
	
	std::string header = response.getResponseHeader();
	std::string body = response.getResponseBody();
	size_t MAX_SEND = response.getBodySize() + response.getHeaderSize() + 1;

	char * buffer = new char[MAX_SEND];
	bzero(buffer, MAX_SEND);

	memcpy(buffer, header.data(), header.length());
	memcpy(buffer + header.length(), body.data(), body.length());
	
	send(sender_fd, buffer, MAX_SEND, 0);
	if (DEBUG)
		std::cout << GREEN << "+++ RESPONSE +++\n\n" << END << buffer << std::endl;

	delete [] buffer;
}

// Server Main Loop. This is where the magic operates
void Server::run(Sockets socket)
{
	pfds.push_back(addToPollfd(socket.getServFD()));
	pfds[0].events = POLLIN;

	std::cout << YELLOW << "Server is listening on: " << socket.getHostName() << END << std::endl;

	while(true) {
		if (poll(&(pfds.front()), pfds.size(), 60000) < 0) {
			perror("poll"); 
			exit(1);
		}

		for (PollIterator it = pfds.begin(); it != pfds.end(); it++) {
			if ((*it).revents & POLLIN) {
				if ((*it).fd == socket.getServFD())
					handleEvents(it);	
				else
					handleClient(it);
			}
		}
	}
}

