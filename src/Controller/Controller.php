<?php

declare(strict_types=1);

namespace App\Controller;

use Symfony\Component\HttpFoundation\BinaryFileResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\StreamedJsonResponse;
use Symfony\Component\HttpFoundation\StreamedResponse;
use Symfony\Component\HttpKernel\Attribute\MapQueryParameter;
use Symfony\Component\Routing\Attribute\Route;

final readonly class Controller
{
    private const int DEFAULT_COUNT = 1_000_000;

    #[Route]
    public function streamedResponse(
        #[MapQueryParameter(options: ['min_range' => 1], validationFailedStatusCode: Response::HTTP_BAD_REQUEST)]
        int $count = self::DEFAULT_COUNT,
    ): StreamedResponse {
        return new StreamedResponse(
            $this->getItemsString($count),
        );
    }

    #[Route(path: '/echo')]
    public function streamedResponseUsedEcho(
        #[MapQueryParameter(options: ['min_range' => 1], validationFailedStatusCode: Response::HTTP_BAD_REQUEST)]
        int $count = self::DEFAULT_COUNT,
    ): StreamedResponse {
        return new StreamedResponse(function() use ($count): void {
            foreach ($this->getItemsString($count) as $item) {
                echo $item;
                @ob_flush();
                flush();
            }
        });
    }

    #[Route(path: '/json')]
    public function streamedJsonResponse(
        #[MapQueryParameter(options: ['min_range' => 1], validationFailedStatusCode: Response::HTTP_BAD_REQUEST)]
        int $count = self::DEFAULT_COUNT,
    ): StreamedJsonResponse
    {
        return new StreamedJsonResponse($this->getItems($count));
    }

    #[Route(path: '/file')]
    public function binaryFileResponse(
        #[MapQueryParameter(options: ['min_range' => 1], validationFailedStatusCode: Response::HTTP_BAD_REQUEST)]
        int $size = 60,
    ): BinaryFileResponse
    {
        $file = __DIR__.'/file.txt';
        if (file_exists($file)) {
            unlink($file);
        }
        exec(sprintf('fallocate -l %dM %s', $size, $file));

        return new BinaryFileResponse(
            file: $file,
            headers: [
                'Content-Type' => 'text/plain;charset=UTF-8',
                'Content-Disposition' => 'attachment',
            ],
        );
    }

    #[Route(path: '/common')]
    public function commonResponse(): Response
    {
        return new Response('Some common response content.');
    }

    /**
     * @param non-negative-int $count
     */
    private function getItems(int $count): \Generator
    {
        for ($i = 0; $i < $count; ++$i) {
            yield new readonly class($i + 1) {
                public string $title;
                public string $description;
                public bool $enabled;

                public function __construct(public int $id)
                {
                    $this->title = 'Title';
                    $this->description = 'Description';
                    $this->enabled = true;
                }
            };
        }
    }

    /**
     * @param non-negative-int $count
     */
    private function getItemsString(int $count): \Generator
    {
        foreach ($this->getItems($count) as $item) {
            yield \sprintf(
                'id: %s; title: %s; description: %s; enabled: %s'.PHP_EOL,
                $item->id,
                $item->title,
                $item->description,
                $item->enabled ? 'true' : 'false',
            );
        }
    }
}
